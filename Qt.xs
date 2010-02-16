#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <stdio.h>
#include <stdlib.h>

#include "smoke.h"

#include "marshall.h"
#include "Qt.h"
#include "smokeperl.h"
#include "perlqt.h"
#include "handlers.h"
#include "marshall_types.h"

#ifdef do_open
#undef do_open
#endif

#ifdef do_close
#undef do_close
#endif
#include "QtCore/QAbstractItemModel"
#include "QtCore/QHash"
#include "QtCore/QList"
#include "QtCore/QMetaObject"
#include "QtCore/QMetaMethod"
#include "QtCore/QModelIndex"
#include "QtCore/QObject"
#include "QtGui/QPainter"
#include "QtGui/QWidget"

extern Q_DECL_EXPORT Smoke *qt_Smoke;
extern Q_DECL_EXPORT void init_qt_Smoke();
extern TypeHandler Qt_handlers[];

SV *sv_this = 0;
HV *pointer_map = 0;
int do_debug = qtdb_none;

int myargc = 1;
char **myargv = new char*[1];
void* qapp = 0;

QHash<Smoke*, PerlQtModule> perlqt_modules;
static PerlQt::Binding binding;

// There's a comment in QtRuby about possible memory leaks with this...
QHash<QByteArray, Smoke::Index *> methcache;

SV *prettyPrintMethod(Smoke::Index id);

Smoke::Index getMethod(Smoke *smoke, const char* c, const char* m) {
    Smoke::Index method = smoke->findMethod(c, m).index;
    Smoke::Index i = smoke->methodMaps[method].method;
    if(i == 0) {
        // ambiguous method have i < 0; it's possible to resolve them, see the other bindings
        fprintf(stderr, "%s method %s::%s\n", "Unknown", c, m);
    }
    return i;
}

bool argmatch( Smoke::Index methodIndex, SV** _sp ) {
    Smoke::Method method = qt_Smoke->methods[methodIndex];
    if( !method.numArgs ) return true;
    Smoke::Index* args = qt_Smoke->argumentList + method.args;

    // Compare this method's arguments with perl's arguments
    bool argmatch = false;
    for(int i=0; i<method.numArgs; i++) {
        SmokeType curType( qt_Smoke, args[i] );


        if( curType.isClass() ) {
            // Test to see if the perl argument is the same class type
            smokeperl_object *o = sv_obj_info(_sp[i]);
            SmokeClass perlClass(qt_Smoke, o->classId);
            SmokeClass curArgClass(qt_Smoke, curType.classId());
            if(o && (perlClass.isa(curArgClass)) )
                argmatch = true;
            else {
                argmatch = false;
                break;
            }
        }
        else {
            QString name(curType.name());
            // Remove leading const and trailing &/*
            static QRegExp* rx = 0;
            if (rx == 0) {
                rx = new QRegExp("const (.*)[*&]");
            }
            name.replace(*rx, "\\1");

            // Check for QString validity
            if(((name == "QString") || (name == "char")) && SvPOK(_sp[i])) {
                argmatch = true;
            }
            // Check for numerical validity
            else if((name == "double") && SvNOK(_sp[i])) {
                argmatch = true;
            }
            // Valid cases are iok, uok, or it's a ref of type SVt_PVMG
            else if((name == "int" || name == "uint") &&
                (SvIOK(_sp[i]) || SvUOK(_sp[i]) || 
                (SvROK(_sp[i]) && SvTYPE(SvRV(_sp[i])) == SVt_PVMG) )) {
                argmatch = true;
            }
            // Check for enumerations.  They will be blessed into a package
            // that has the same name as the name of the argument.
            else if(SvROK(_sp[i]) && (name == HvNAME(SvSTASH(SvRV(_sp[i]))))) {
                argmatch = true;
            }
            else {
                argmatch = false;
                break;
            }
        }
    }
    return argmatch;
}

Smoke::Index resolveMethod( Smoke::Index methodIndex, SV** _sp ) {
    methodIndex = -methodIndex; // turn into ambiguousMethodList index
    while(qt_Smoke->ambiguousMethodList[methodIndex]) {
        Smoke::Index curIdx = qt_Smoke->ambiguousMethodList[methodIndex];
        if(do_debug && (do_debug & qtdb_ambiguous)) 
            fprintf(stderr, "Testing method\t%d\t%s\n", curIdx, SvPV_nolen(sv_2mortal(prettyPrintMethod(curIdx))));

        if( argmatch( curIdx, _sp ) ){
            if(do_debug && (do_debug & qtdb_ambiguous)) 
                fprintf( stderr, "Returning %d\n", curIdx );
            return curIdx;
        }
        ++methodIndex;
    }

    return 0;
}


void callMethod(Smoke *smoke, void *obj, Smoke::Index method, Smoke::Stack args) {
    Smoke::Method *m = smoke->methods + method;
    Smoke::ClassFn fn = smoke->classes[m->classId].classFn;
    fn(m->method, obj, args);
    if(m->flags & Smoke::mf_ctor){
        Smoke::StackItem s[2];
        s[1].s_voidp = perlqt_modules[smoke].binding;
        (*fn)(0, args[0].s_voidp, s);
    }
}

void smokeCast(Smoke *smoke, Smoke::Index method, Smoke::Stack args, Smoke::Index i, void *obj, const char *className) {
    // cast obj from className to the desired type of args[i]
    Smoke::Index arg = smoke->argumentList[
        smoke->methods[method].args + i - 1
    ];
    // cast(obj, from_type, to_type)
    args[i].s_class = smoke->cast(obj, smoke->idClass(className).index, smoke->types[arg].classId);
}

void smokeCastThis(Smoke *smoke, Smoke::Index method, Smoke::Stack args, void *obj, const char *className) {
    args[0].s_class = smoke->cast(obj, smoke->idClass(className).index, smoke->methods[method].classId);
}
// Given the perl package, look up the smoke classid
// Depends on the classcache_ext hash being defined, which gets set in the
// init_class function in Qt::_internal
Smoke::Index package_classid(const char *package) {
    // Get the cache hash
    HV* classcache_ext = get_hv( "Qt::_internal::package2classid", false);
    U32 klen = strlen( package );
    SV** classcache = hv_fetch( classcache_ext, package, klen, 0 );
    Smoke::Index item = 0;
    if( classcache ) {
        item = SvIV( *classcache );
    }
    if(item){
        return item;
    }

    // Get the ISA array, nisa is a temp string to build package::ISA
    char *nisa = new char[strlen(package)+6];
    sprintf(nisa, "%s::ISA", package);
    AV* isa=get_av(nisa, true);
    delete[] nisa;

    // Loop over the ISA array
    for(int i=0; i<=av_len(isa); i++) {
        // Get the value of the current index into @isa
        SV** np = av_fetch(isa, i, 0); // np = 'new package'?
        if(np) {
            // Recurse until we find a match
            Smoke::Index ix = package_classid(SvPV_nolen(*np));
            if(ix) {
                ;// Cache the result - to do, does it depend on cache?
                return ix;
            }
        }
    }
    // Found nothing, so
    return (Smoke::Index) 0;
}

// The pointer map gives us the relationship between an arbitrary c++ pointer
// and a perl SV.  If you have a virtual function call, you only start with a
// c++ pointer.  This reference allows you to trace back to a perl package, and
// find a subroutine in that package to call.
SV *getPointerObject(void *ptr) {
    HV *hv = pointer_map;
    SV *keysv = newSViv((IV)ptr);
    STRLEN len;
    char *key = SvPV(keysv, len);
    // Look to see in the pointer_map for a ptr->perlSV reference
    SV **svp = hv_fetch(hv, key, len, 0);
    // Nothing found, exit out
    if(!svp){
        SvREFCNT_dec(keysv);
        return 0;
    }
    // Corrupt entry, not sure how this would happen
    if(!SvOK(*svp)){
        hv_delete(hv, key, len, G_DISCARD);
        SvREFCNT_dec(keysv);
        return 0;
    }
    SvREFCNT_dec(keysv);
    return *svp;
}

// Store pointer in pointer_map hash : "pointer_to_Qt_object" => weak ref to associated Perl object
// Recurse to store it also as casted to its parent classes.
void mapPointer(SV *obj, smokeperl_object *o, HV *hv, Smoke::Index classId, void *lastptr) {
    void *ptr = o->smoke->cast(o->ptr, o->classId, classId);
    // This ends the recursion
    if(ptr != lastptr) {
        lastptr = ptr;
        SV *keysv = newSViv((IV)ptr);
        STRLEN len;
        char *key = SvPV(keysv, len);
        SV *rv = newSVsv(obj);
        sv_rvweaken(rv); // weak reference! What's this?
        hv_store(hv, key, len, rv, 0);
        SvREFCNT_dec(keysv);
    }
    for(Smoke::Index *i = o->smoke->inheritanceList + o->smoke->classes[classId].parents; *i; i++) {
        mapPointer(obj, o, hv, *i, lastptr);
    }
}

void unmapPointer(smokeperl_object *o, Smoke::Index classId, void *lastptr) {
    //For object deletion
}

char *get_SVt(SV *sv) {
    char *r;
    if(!SvOK(sv))
        r = "u";
    else if(SvIOK(sv))
        r = "i";
    else if(SvNOK(sv))
        r = "n";
    else if(SvPOK(sv))
        r = "s";
    else if(SvROK(sv)) {
        smokeperl_object *o = sv_obj_info(sv);
        if(!o) {
            switch (SvTYPE(SvRV(sv))) {
                case SVt_PVAV:
                  r = "a";
                  break;
                case SVt_PVMG:
                  r = HvNAME(SvSTASH(SvRV(sv)));
                default:
                  r = "r";
            }
        }
        else
            r = (char*)o->smoke->className(o->classId);
    }
    else
        r = "U";
    return r;
}

SV *prettyPrintMethod(Smoke::Index id) {
    SV *r = newSVpvf("");
    Smoke::Method &meth = qt_Smoke->methods[id];
    const char *tname = qt_Smoke->types[meth.ret].name;
    if(meth.flags & Smoke::mf_static) sv_catpv(r, "static ");
    sv_catpvf(r, "%s ", (tname ? tname:"void"));
    sv_catpvf(r, "%s::%s(", qt_Smoke->classes[meth.classId].className, qt_Smoke->methodNames[meth.name]);
    for(int i = 0; i < meth.numArgs; i++) {
        if(i) sv_catpv(r, ", ");
        tname = qt_Smoke->types[qt_Smoke->argumentList[meth.args+i]].name;
        sv_catpv(r, (tname ? tname:"void"));
    }
    sv_catpv(r, ")");
    if(meth.flags & Smoke::mf_const) sv_catpv(r, " const");
    return r;
}

SV *catArguments(SV** sp, int n) {
    SV* r=newSVpvf("");
    for(int i = 0; i < n; i++) {
        if(i) sv_catpv(r, ", ");
        if(!SvOK(sp[i])) {
            sv_catpv(r, "undef");
        } else if(SvROK(sp[i])) {
            smokeperl_object *o = sv_obj_info(sp[i]);
            if(o)
                sv_catpv(r, o->smoke->className(o->classId));
            else if (SvTYPE(SvRV(sp[i])) == SVt_PVMG)
                sv_catpvf(r, "%s(%s)", HvNAME(SvSTASH(SvRV(sp[i]))), SvPV_nolen(SvRV(sp[i])));
            else
                sv_catsv(r, sp[i]);
        } else {
            bool isString = SvPOK(sp[i]);
            STRLEN len;
            char *s = SvPV(sp[i], len);
            if(isString) sv_catpv(r, "'");
            sv_catpvn(r, s, len > 10 ? 10 : len);
            if(len > 10) sv_catpv(r, "...");
            if(isString) sv_catpv(r, "'");
        }
    }
    return r;
}

XS(XS_Qt__myQAbstractItemModel_flags){
    dXSARGS;
    if( do_debug && ( do_debug | qtdb_autoload ) )
        fprintf( stderr, "In XS Custom   for Qt::QAbstractItemModel::flags\n" );

    char *classname = "QAbstractItemModel";
    char *methodname = "flags#";

    Smoke::Index methodIndex = getMethod(qt_Smoke, classname, methodname );

    /*
    //Method 1
    QAbstractItemModel* mythis = (QAbstractItemModel*)sv_obj_info(sv_this)->ptr;
    QModelIndex* modelix = (QModelIndex*)sv_obj_info( ST(0) )->ptr;
    SV* retval = newSViv(mythis->QAbstractItemModel::flags( *modelix ));

    //Method 2
    Smoke::StackItem args[items + 1];
    // ST(0) should contain 'this'.  ST(1) is the 1st arg.
    args[1].s_voidp = sv_obj_info( ST(1) )->ptr;
    callMethod( qt_Smoke, sv_obj_info(sv_this)->ptr, methodIndex, args );
    SV* retval = newSViv(args[0].s_int);
    */

    //Method 3
    int withObject = 1;
    PerlQt::MethodCall call( qt_Smoke,
                             methodIndex,
                             sv_obj_info(sv_this),
                             SP - items + 1 + withObject,
                             items - withObject );
    call.next();
    SV* retval = call.var();

    // Put the return value onto perl's stack
    ST(0) = sv_2mortal(retval);
    XSRETURN(1);
}

XS(XS_Qt__myQTableView_setRootIndex){
    dXSARGS;
    fprintf( stderr, "In XS Custom   for setRootIndex\n" );
    
    char *classname = "QTableView";
    char *methodname = "setRootIndex#";

    Smoke::StackItem args[items + 1];
    args[1].s_voidp = sv_obj_info( ST(1) )->ptr;

    Smoke::Index methodIndex = getMethod(qt_Smoke, classname, methodname );

    PerlQt::MethodCall call( qt_Smoke, methodIndex, sv_obj_info(ST(0)), SP - items + 2, items - 1 );
    call.next();

    SV* retval = call.var();

    // Put the return value onto perl's stack
    ST(0) = sv_2mortal(retval);
    XSRETURN(1);
}

QList<MocArgument*> get_moc_arguments(Smoke* smoke, const char * typeName, QList<QByteArray> methodTypes) {
    static QRegExp * rx = 0;
	if (rx == 0) {
		rx = new QRegExp("^(bool|int|uint|long|ulong|double|char\\*|QString)&?$");
	}
	methodTypes.prepend(QByteArray(typeName));
	QList<MocArgument*> result;

	foreach (QByteArray name, methodTypes) {
		MocArgument *arg = new MocArgument;
		Smoke::Index typeId = 0;

		if (name.isEmpty()) {
			arg->argType = xmoc_void;
			result.append(arg);
		} else {
			name.replace("const ", "");
			QString staticType = (rx->indexIn(name) != -1 ? rx->cap(1) : "ptr");
			if (staticType == "ptr") {
				arg->argType = xmoc_ptr;
				QByteArray targetType = name;
				typeId = smoke->idType(targetType.constData());
				if (typeId == 0 && !name.contains('*')) {
					if (!name.contains("&")) {
						targetType += "&";
					}
					typeId = smoke->idType(targetType.constData());
				}

				// This shouldn't be necessary because the type of the slot arg should always be in the 
				// smoke module of the slot being invoked. However, that isn't true for a dataUpdated()
				// slot in a PlasmaScripting::Applet
				if (typeId == 0) {
					QHash<Smoke*, PerlQtModule>::const_iterator it;
					for (it = perlqt_modules.constBegin(); it != perlqt_modules.constEnd(); ++it) {
						smoke = it.key();
						targetType = name;
						typeId = smoke->idType(targetType.constData());
						if (typeId != 0) {
							break;
						}
	
						if (typeId == 0 && !name.contains('*')) {
							if (!name.contains("&")) {
								targetType += "&";
							}

							typeId = smoke->idType(targetType.constData());
	
							if (typeId != 0) {
								break;
							}
						}
					}
				}			
			} else if (staticType == "bool") {
				arg->argType = xmoc_bool;
				smoke = qt_Smoke;
				typeId = smoke->idType(name.constData());
			} else if (staticType == "int") {
				arg->argType = xmoc_int;
				smoke = qt_Smoke;
				typeId = smoke->idType(name.constData());
			} else if (staticType == "uint") {
				arg->argType = xmoc_uint;
				smoke = qt_Smoke;
				typeId = smoke->idType(name.constData());
			} else if (staticType == "long") {
				arg->argType = xmoc_long;
				smoke = qt_Smoke;
				typeId = smoke->idType(name.constData());
			} else if (staticType == "ulong") {
				arg->argType = xmoc_ulong;
				smoke = qt_Smoke;
				typeId = smoke->idType(name.constData());
			} else if (staticType == "double") {
				arg->argType = xmoc_double;
				smoke = qt_Smoke;
				typeId = smoke->idType(name.constData());
			} else if (staticType == "char*") {
				arg->argType = xmoc_charstar;
				smoke = qt_Smoke;
				typeId = smoke->idType(name.constData());
			} else if (staticType == "QString") {
				arg->argType = xmoc_QString;
				name += "*";
				smoke = qt_Smoke;
				typeId = smoke->idType(name.constData());
			}

			if (typeId == 0) {
				croak("Cannot handle '%s' as slot argument\n", name.constData());
				return result;
			}

			arg->st.set(smoke, typeId);
			result.append(arg);
		}
	}

	return result;
}

XS(XS_qt_metacall){
    dXSARGS;
    PERL_UNUSED_VAR(items);

    // Get my arguments off the stack
    QObject* sv_this_ptr = (QObject*)sv_obj_info(sv_this)->ptr;
    // This is an enum value, so it's stored as a scalar reference.
    QMetaObject::Call _c = (QMetaObject::Call)SvIV(SvRV(ST(0)));
    int _id = (int)SvIV(ST(1));
    void** _a = (void**)sv_obj_info(ST(2))->ptr;

	// Assume the target slot is a C++ one
	smokeperl_object *o = sv_obj_info(sv_this);
	Smoke::ModuleIndex nameId = o->smoke->idMethodName("qt_metacall$$?");
	Smoke::ModuleIndex classIdx = { o->smoke, o->classId };
	Smoke::ModuleIndex meth = nameId.smoke->findMethod(classIdx, nameId);
	if (meth.index > 0) {
		Smoke::Method &m = meth.smoke->methods[meth.smoke->methodMaps[meth.index].method];
		Smoke::ClassFn fn = meth.smoke->classes[m.classId].classFn;
		Smoke::StackItem i[4];
		i[1].s_enum = _c;
		i[2].s_int = _id;
		i[3].s_voidp = _a;
		(*fn)(m.method, o->ptr, i);
		int ret = i[0].s_int;
		if (ret < 0) {
            ST(0) = sv_2mortal(newSViv(ret));
			XSRETURN(1);
		}
	} else {
		// Should never happen..
		//rb_raise(rb_eRuntimeError, "Cannot find %s::qt_metacall() method\n", 
		//	o->smoke->classes[o->classId].className );
	}

    // Get the current metaobject with a virtual call
    const QMetaObject* metaobject = sv_this_ptr->metaObject();

	// get method/property count
	int count = 0;
	if (_c == QMetaObject::InvokeMetaMethod) {
		count = metaobject->methodCount();
	} else {
		count = metaobject->propertyCount();
	}

    if (_c == QMetaObject::InvokeMetaMethod) {
        QMetaMethod method = metaobject->method(_id);

        // Signals are easy, just activate the meta object
        if (method.methodType() == QMetaMethod::Signal) {
            //fprintf( stderr, "In signal for %s::%s\n", metaobject->className(), method.signature() );
            metaobject->activate(sv_this_ptr, metaobject, 0, _a);
            ST(0) = sv_2mortal(newSViv(_id - count));
            XSRETURN(1);
        }
        else if (method.methodType() == QMetaMethod::Slot) {

            // Get the smoke to type id relationship args
            QList<MocArgument*> mocArgs = get_moc_arguments(o->smoke, method.typeName(), method.parameterTypes());

            // Find the name of the method being called
            QString name(method.signature());
            static QRegExp* rx = 0;
            if (rx == 0) {
                rx = new QRegExp("\\(.*");
            }
            name.replace(*rx, "");

            PerlQt::InvokeSlot slot( sv_this, name.toLatin1().data(), mocArgs, _a );
            slot.next();
        }
    }

    ST(0) = sv_2mortal(newSViv(_id - count));
    XSRETURN(1);
}

XS(XS_AUTOLOAD){
    dXSARGS;
    SV *autoload = get_sv("Qt::AutoLoad::AUTOLOAD", TRUE);
    char *package = SvPV_nolen(autoload);
    char *methodname = 0;
    // Splits off the method name from the package.
    for(char *s = package; *s; s++ ) {
        if(*s == ':') methodname = s;
    }
    // No method to call was passed, so error out
    if(!methodname) XSRETURN_NO;

    // Erases the first character off the method, killing the ':', and truncate
    // the value of method off package.
    *(methodname++ - 1) = 0;    

    int withObject = (*package == ' ') ? 1 : 0;
    int isSuper = 0;
    if(withObject) {
        package++;
        if(*package == ' ') {
            isSuper = 1;
            package++;
            char *super = new char[strlen(package) + 7];
            sprintf( super, "%s::SUPER", package );
            package = super;
        }
    }

    if( do_debug && ( do_debug & qtdb_autoload ) ) {
        fprintf(stderr, "In XS Autoload for %s::%s()", package, methodname);
        if((do_debug & qtdb_verbose) && (withObject || isSuper)) {
            smokeperl_object *o = sv_obj_info(withObject ? ST(0) : sv_this);
            if(o)
                fprintf(stderr, " - this: (%s)%p\n", o->smoke->classes[o->classId].className, o->ptr);
            else
                fprintf(stderr, " - this: (unknown)(nil)\n");
        }
        else {
            fprintf(stderr, "\n");
        }
    }

    HV *stash = gv_stashpv(package, TRUE);
    GV *gv = gv_fetchmethod_autoload(stash, methodname, 0);

    if(gv){
        if(do_debug && (do_debug & qtdb_autoload))
            fprintf(stderr, "\t%s::%s found in Perl stash\n", package, methodname);

        SV *old_this = 0;
        if(withObject && !isSuper){
            old_this = sv_this;
            sv_this = newSVsv(ST(0));
        }

        // Call the found method
        ENTER;
        SAVETMPS;
        PUSHMARK(SP - items + withObject);
        // What context are we calling this subroutine in?
        I32 gimme = GIMME_V;
        // Make the call, save number of returned values
        int count = call_sv((SV*)GvCV(gv), gimme|G_EVAL);
        // Get the return value
        SPAGAIN;
        SP -= count;
        if (withObject)
            for (int i=0; i<count; i++)
                ST(i) = ST(i+1);
        PUTBACK;
        //FREETMPS;
        //LEAVE;

        // Clean up
        if(withObject && !isSuper){
            SvREFCNT_dec(sv_this);
            sv_this = old_this;
        }
        else if(isSuper)
            delete[] package;

        // Error out if necessary
        if(SvTRUE(ERRSV))
            croak(SvPV_nolen(ERRSV));
        if (gimme == G_VOID)
            XSRETURN_UNDEF;
        else
            XSRETURN(count);
    }
    else if(!strcmp(methodname, "DESTROY")) {
        //fprintf( stderr, "DESTROY: coming soon.\n" );
    }
    else {
        Smoke::Index classid = package_classid(package);
        char *classname = (char*)qt_Smoke->className(classid);
        Smoke::Index methodid = 0;

        // Look in the cache; if this method was called before with the same
        // arguments, we already know the methodid
        // The key to the methodcache looks like this:
        // class      method     arg types
        // QPopupMenu;insertItem;s;QApplication;s
        int lclassname = strlen(classname);
        int lmethodname = strlen(methodname);
        char mcid[256];
        strncpy(mcid, classname, lclassname);
        char *ptr = mcid + lclassname;
        *(ptr++) = ';'; //Set the current position to ; then increment
        strncpy(ptr, methodname, lmethodname);
        ptr += lmethodname;

        // that gives us the first 2 parts of the methcache key, now for the
        // args
        for(int i = withObject; i < items; i++) {
            *(ptr++) = ';';
            char *type = get_SVt(ST(i));
            int typelen = strlen(type);
            strncpy(ptr, type, typelen );
            ptr += typelen;
        }
        *ptr = 0; // Don't forget to null-terminate the string

        // See if it's cached
        Smoke::Index* rcid = methcache.value(mcid);
        if(rcid) {
            // Got a hit
            methodid = *rcid;
        }
        else {
            // Loop over the arguments and see what kind we have
            for(int i = withObject; i < items; i++) {
                SV* arg = ST(i);
                if( sv_obj_info( arg ) ){
                    strcat( methodname, "#" );
                }
                else if( SvROK(arg) && (SvTYPE(SvRV(arg)) == SVt_PVAV || SvTYPE(SvRV(arg)) == SVt_PVHV ) ) {
                    strcat( methodname, "?" );
                }
                else if( SvIOK(arg) || SvNOK(arg) || SvPOK(arg) || SvUOK(arg) || (SvROK(arg) && SvTYPE(SvRV(arg)) == SVt_PVMG) ){
                    strcat( methodname, "$" );
                }
            }

            methodid = getMethod( qt_Smoke, classname, methodname );

            // The lookup for the methodid resulted in an ambiguous method.  Run
            // resolveMethod on the returned id to run argMatch on each possible
            // methodid to find the correct method.
            if(methodid < 0) {
                if(do_debug && (do_debug & qtdb_ambiguous)){
                    fprintf(stderr, "Ambiguous method %s\n", methodname);
                    if(do_debug & qtdb_verbose) {
                        fprintf(stderr, "with arguments (%s)\n", SvPV_nolen(sv_2mortal(catArguments(SP - items + 1 + withObject, items - withObject))));
                    }
                }
                methodid = resolveMethod( methodid, SP - items + 1 + withObject );
            }
            // Make sure we're good
            // Not sure we want to do this...
            /*
            else {
                if( !argmatch( methodid, SP - items + 1 + withObject ) )
                    croak( "--- Arguments don't match for %d %s::%s:\n%s\n%s\n", methodid, classname, methodname,
                               SvPV_nolen(sv_2mortal(prettyPrintMethod(methodid))),
                               SvPV_nolen(sv_2mortal(catArguments(SP - items + 1 + withObject, items - withObject))) );
            }
            */

            // Make sure the resolveMethod resolved the method.
            if(methodid == 0) {
                croak( "--- No method to call for %s::%s\n", classname, methodname );
            }

            // Save our lookup
            methcache.insert(mcid, new Smoke::Index(methodid));
        }

        if(do_debug && (do_debug & qtdb_calls)) {
            fprintf(stderr, "Calling method\t%s\t%s\n", methodname, SvPV_nolen(sv_2mortal(prettyPrintMethod(methodid))));
            if(do_debug & qtdb_verbose) {
                fprintf(stderr, "with arguments (%s)\n", SvPV_nolen(sv_2mortal(catArguments(SP - items + 1 + withObject, items - withObject))));
            }
        }

        static smokeperl_object nothis = { 0, 0, 0, false };
        smokeperl_object *call_this = 0;
        if( withObject ){
            if( isSuper ){
                call_this = sv_obj_info( sv_this );
            }
            else {
                call_this = sv_obj_info( ST(0) );
            }
        }
        else{
            call_this = &nothis;
        }

        // We need current_object, methodid, and args to call the method
        PerlQt::MethodCall call( qt_Smoke,
                         methodid,
                         call_this,
                         SP - items + 1 + withObject,
                         items  - withObject );
        call.next();

        SV* retval = call.var();

        // Put the return value onto perl's stack
        ST(0) = sv_2mortal(retval);
        XSRETURN(1);
    }
}

XS(XS_signal){
    dXSARGS;

    smokeperl_object *o = sv_obj_info(sv_this);
    QObject *qobj = (QObject*)o->smoke->cast( o->ptr, o->classId, o->smoke->idClass("QObject").index );
    if(qobj->signalsBlocked()) XSRETURN_UNDEF;

    // Each xs method has an implied cv argument that holds the info for the
    // called subroutine.  Use it to determine the name of the signal being
    // called.
    GV* gv = CvGV(cv);
    QLatin1String signalname( GvNAME(gv) );
    if(do_debug && (do_debug & qtdb_signals)){
        char* package = HvNAME( GvSTASH(gv) );
        fprintf( stderr, "In signal call %s::%s\n", package, GvNAME(gv) );
        if(do_debug & qtdb_verbose) {
            fprintf(stderr, "with arguments (%s) ", SvPV_nolen(sv_2mortal(catArguments(SP - items + 1, items ))));
            // See cop.h in the perl src for more info on Control ops
            fprintf(stderr, "called at line %lu in %s\n", CopLINE(PL_curcop), GvNAME(CopFILEGV(PL_curcop))+2 );
        }
    }

    // Get the current metaobject with a virtual call
    const QMetaObject* metaobject = qobj->metaObject();

    // Find the method's meta id.  This loop is easier than building the method
    // signature to send to indexOfMethod, but makes it impossible to make 2
    // signals with different signatures.
    int index = -1;
    for (index = metaobject->methodCount() - 1; index > -1; index--) {
		if (metaobject->method(index).methodType() == QMetaMethod::Signal) {
			QString name(metaobject->method(index).signature());
            static QRegExp * rx = 0;
			if (rx == 0) {
				rx = new QRegExp("\\(.*");
			}
			name.replace(*rx, "");

			if (name == signalname) {
				break;
			}
		}
    }

	if (index == -1) {
		XSRETURN_UNDEF;
	}
    QMetaMethod method = metaobject->method(index);
    QList<MocArgument*> args = get_moc_arguments(o->smoke, method.typeName(), method.parameterTypes());

    SV* retval = &PL_sv_undef;

    PerlQt::EmitSignal signal(qobj, index, items, args, SP, retval);
    signal.next();
}

XS(XS_super) {
    dXSARGS;
    PERL_UNUSED_VAR(items);
    SV **svp = 0;
    // If we have a valid 'sv_this'
    if(SvROK(sv_this) && SvTYPE(SvRV(sv_this)) == SVt_PVHV){
        // Get the reference to this object's super hash
        HV *copstash = (HV*)CopSTASH(PL_curcop); //wtf is the cop?
        if(!copstash) XSRETURN_UNDEF;
        
        // Get the _INTERNAL_STATIC_ hash
        svp = hv_fetch(copstash, "_INTERNAL_STATIC_", 17, 0);
        if(!svp) XSRETURN_UNDEF;
        
        // Get the glob value from that hash key
        copstash = GvHV((GV*)*svp);
        if(!copstash) XSRETURN_UNDEF;
        
        svp = hv_fetch(copstash, "SUPER", 5, 0);
    }
    if(svp) {
        ST(0) = *svp;
        XSRETURN(1);
    }
}

XS(XS_this) {
    dXSARGS;
    PERL_UNUSED_VAR(items);
    ST(0) = sv_this;
    XSRETURN(1);
}

MODULE = Qt   PACKAGE = Qt::_internal

PROTOTYPES: DISABLE

SV*
gimmePainter(sv_widget)
        SV* sv_widget
    CODE:
        smokeperl_object *o = sv_obj_info(sv_widget);

        //char* package = "Qt::QPainter";
        //Smoke::Index classid = package_classid(package);
        //char* classname = (char*)qt_Smoke->className(classid);
        char* classname = "QPainter";
        char* methodname = "QPainter#";
        Smoke::Index methodid = getMethod(qt_Smoke, classname, methodname);

        Smoke::StackItem args[2];
        smokeCast( qt_Smoke, methodid, args, 1, o->ptr, "QWidget" );
        callMethod( qt_Smoke, 0, methodid, args );
        //args[0].s_class = new QPainter((QWidget*)o->ptr);

        HV *hv = newHV();
        RETVAL = newRV_noinc((SV*)hv);
        sv_bless( RETVAL, gv_stashpv( " Qt::QPainter", TRUE) );

        smokeperl_object o2;
        o2.smoke = qt_Smoke;
        o2.classId = qt_Smoke->idClass("QPainter").index;
        o2.ptr = args[0].s_voidp;
        o2.allocated = true;

        sv_magic((SV*)hv, 0, '~', (char*)&o2, sizeof(o2));

        mapPointer(RETVAL, &o2, pointer_map, o2.classId, 0);
    OUTPUT:
        RETVAL

SV *
getClassList()
    CODE:
        AV *av = newAV();
        for(int i = 1; i < qt_Smoke->numClasses; i++) {
            av_push(av, newSVpv(qt_Smoke->classes[i].className, 0));
        }
        RETVAL = newRV((SV*)av);
    OUTPUT:
        RETVAL

SV *
getEnumList()
    CODE:
        AV *av = newAV();
        for(int i = 1; i < qt_Smoke->numTypes; i++) {
            Smoke::Type curType = qt_Smoke->types[i];
            if( (curType.flags & Smoke::tf_elem) == Smoke::t_enum )
                av_push(av, newSVpv(curType.name, 0));
        }
        RETVAL = newRV((SV*)av);
    OUTPUT:
        RETVAL

# Necessary to get any method call on an already constructed object to work.
void
getIsa(classId)
        int classId
    PPCODE:
        Smoke::Index *parents =
            qt_Smoke->inheritanceList +
            qt_Smoke->classes[classId].parents;
        while(*parents)
            XPUSHs(sv_2mortal(newSVpv(qt_Smoke->classes[*parents++].className, 0)));

int
idClass(name)
        char *name
    CODE:
        RETVAL = qt_Smoke->idClass(name).index;
    OUTPUT:
        RETVAL

void
installautoload(package)
        char *package
    CODE:
        if(!package) XSRETURN_EMPTY;
        char *autoload = new char[strlen(package) + 11];
        strcpy(autoload, package);
        strcat(autoload, "::_UTOLOAD");
        char *file = __FILE__;
        newXS(autoload, XS_AUTOLOAD, file);
        delete[] autoload;

void
installsignal(signalname)
        char *signalname
    CODE:
        if(!signalname) XSRETURN_EMPTY;
        newXS(signalname, XS_signal, __FILE__);

void
installqt_metacall(package)
        char *package
    CODE:
        if(!package) XSRETURN_EMPTY;
        char *qt_metacall = new char[strlen(package) + 14];
        sprintf(qt_metacall, "%s::qt_metacall", package);
        newXS(qt_metacall, XS_qt_metacall, __FILE__);
        delete[] qt_metacall;

void
installsuper(package)
        char *package
    CODE:
        if(!package) XSRETURN_EMPTY;
        char *attr = new char[strlen(package) + 8];
        sprintf(attr, "%s::SUPER", package);
        // *{ $name } = sub () : lvalue;
        CV *attrsub = newXS(attr, XS_super, __FILE__);
        sv_setpv((SV*)attrsub, ""); // sub this () : lvalue; perldoc perlsub
        delete[] attr;

void
installthis(package)
        char *package
    CODE:
        if(!package) XSRETURN_EMPTY;
        char *attr = new char[strlen(package) + 7];
        sprintf(attr, "%s::this", package);
        // *{ $name } = sub () : lvalue;
        CV *attrsub = newXS(attr, XS_this, __FILE__);
        sv_setpv((SV*)attrsub, ""); // sub this () : lvalue; perldoc perlsub
        delete[] attr;

SV*
make_metaObject(parentClassId,parentMeta,stringdata_sv,data_sv)
        SV* parentClassId
        SV* parentMeta
        SV* stringdata_sv
        SV* data_sv
    CODE:
        // Get the meta object of the super class, to inherit the super's
        // sig/slots
        QMetaObject* superdata;
        if( !SvROK(parentMeta) ){
            // The parent class is a Smoke class, so call metaObject() on the
            // instance to get it via a smoke library call
            const char* classname = qt_Smoke->classes[SvIV(parentClassId)].className;
            Smoke::Index methodid = getMethod(qt_Smoke, classname, "metaObject");
            Smoke::StackItem args[1];
            callMethod( qt_Smoke, 0, methodid, args );
            superdata = (QMetaObject*) args[0].s_voidp;
        }
        else {
            // The parent class is a custom Perl class whose metaObject
            // was constructed at runtime
            superdata = (QMetaObject*)sv_obj_info(parentMeta)->ptr;
        }

        // Create the qt_meta_data array.
        int count = av_len((AV*)SvRV(data_sv)) + 1;
        uint* qt_meta_data = new uint[count];
        for (int i = 0; i < count; i++) {
            SV** datarow = av_fetch((AV*)SvRV(data_sv), i, 0);
            qt_meta_data[i] = (uint)SvIV(*datarow);
        }

        // Create the qt_meta_stringdata array.
        // Can't use string functions here, because these strings contain
        // null (0) bits, which the string functions will interpret as the end
        // of the string

        // Stole this line from some preprocessed XS code.  Gets the length of
        // stringdata_sv without querying the char* array.
        STRLEN len = ((XPV*)(stringdata_sv)->sv_any)->xpv_cur;
        char* qt_meta_stringdata = new char[len];
        memcpy( (void*)(qt_meta_stringdata), (void*)SvPV_nolen(stringdata_sv), len );

        // Define our meta object
        const QMetaObject staticMetaObject = {
            { superdata, qt_meta_stringdata,
              qt_meta_data, 0 }
        };
        QMetaObject *meta = new QMetaObject;
        *meta = staticMetaObject;

        //Package up this pointer to be returned to perl
        smokeperl_object o;
        o.smoke = qt_Smoke;
        o.classId = qt_Smoke->idClass("QMetaObject").index,
        o.ptr = meta;
        o.allocated = true;

        HV *hv = newHV();
        RETVAL = newRV_noinc((SV*)hv);
        sv_bless( RETVAL, gv_stashpv( " Qt::QMetaObject", TRUE ) );
        sv_magic((SV*)hv, 0, '~', (char*)&o, sizeof(o));
        //Not sure we need the entry in the pointer_map
        mapPointer(RETVAL, &o, pointer_map, o.classId, 0);
    OUTPUT:
        RETVAL    

void
setDebug(on)
        int on
    CODE:
        do_debug = on;

void
setThis(obj)
        SV *obj
    CODE:
        sv_setsv_mg(sv_this, obj);

MODULE = Qt   PACKAGE = Qt

SV *
this()
    CODE:
        RETVAL = newSVsv(sv_this);
    OUTPUT:
        RETVAL

SV *
qapp()
    CODE:
        HV *hv = newHV();
        RETVAL = newRV_noinc((SV*)hv);
        sv_bless( RETVAL, gv_stashpv(" Qt::QApplication", TRUE));
        smokeperl_object o;
        o.smoke = qt_Smoke;
        o.classId = 46;
        o.ptr = qapp;
        o.allocated = true;

        sv_magic((SV*)hv, 0, '~', (char*)&o, sizeof(o));
    OUTPUT:
        RETVAL

BOOT:
    init_qt_Smoke();
    binding = PerlQt::Binding(qt_Smoke);
    PerlQtModule module = { "PerlQt", &binding };
    perlqt_modules[qt_Smoke] = module;

    install_handlers(Qt_handlers);
    sv_this = newSV(0);
    pointer_map = get_hv( "Qt::_internal::pointer_map", FALSE );

    myargv[0] = new char[6];
    strcpy( myargv[0], "Hello");

    //Create the QApplication through smoke
    {
        Smoke::Index methodid = getMethod(qt_Smoke, "QApplication", "QApplication$?" );
        Smoke::StackItem args[3];
        args[1].s_voidp = (void*)&myargc;
        args[2].s_voidp = (void*)myargv;
        //smokeCast( qt_Smoke, methodid, args, 2, myargv, "charp" );
        callMethod( qt_Smoke, 0, methodid, args );
        qapp = args[0].s_voidp;
    }

    newXS("myStringListModel::SUPER::flags", XS_Qt__myQAbstractItemModel_flags, file);
    //newXS(" Qt::QTableView::setRootIndex", XS_Qt__myQTableView_setRootIndex, file);
