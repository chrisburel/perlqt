//util.h brings in all the required Qt4 headers.  This has to happen before the
//perl stuff below
#include "util.h"

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
}

// Now my own headers
#include "smoke.h"
#include "QtCore4.h"
#include "binding.h"
#include "smokeperl.h"
#include "marshall_types.h" // Method call classes
#include "handlers.h" // for install_handlers function

extern PerlQt4::Binding binding;
extern Q_DECL_EXPORT Smoke* qtcore_Smoke;
extern "C" void init_qtcore_Smoke();
extern Q_DECL_EXPORT QHash<Smoke*, PerlQt4Module> perlqt_modules;
extern SV* sv_qapp;
QList<Smoke*> smokeList;

MODULE = Qt4                PACKAGE = Qt4::_internal

PROTOTYPES: DISABLE

int
classIsa( className, base )
        char *className
        char *base
    CODE:
        RETVAL = isDerivedFromByName(className, base, 0);
    OUTPUT:
        RETVAL

#// Args: classname: a c++ classname in which the method exists
#//       methodname: a munged method name signature, where $ is a scalar
#//       argument, ? is an array or hash ref, and # is an object
#// Returns: an array containing 1 method id if the method signature is unique,
#//          or an array of possible ids if the signature is ambiguous
void
findMethod( classname, methodname )
        char* classname
        char* methodname
    PPCODE:
        Smoke::ModuleIndex mi;
        if ( strcmp( classname, "QGlobalSpace" ) == 0 ) {
            // All modules put their global functions in "QGlobalSpace".  So we
            // have to use each smoke object to look for this method.
            for (int i = 0; i < smokeList.size(); ++i) {
                mi = smokeList.at(i)->findMethod(classname, methodname);
                if( mi.smoke ) {
                    break;
                }
            }
        }
        else {
            // qtcore_Smoke will be able to find any method not in QGlobalSpace
            mi = qtcore_Smoke->findMethod(classname, methodname);
        }
        if ( !mi.index ) {
            // empty list
        }
        else if ( mi.index  > 0 ) {
            int smokeId = smokeList.indexOf(mi.smoke);
            if ( smokeId == -1 ) {
                croak( "Method \"%s::%s\" called, which is defined in the smoke"
                    "module \"%s\", which has not been loaded\n", classname,
                    methodname, mi.smoke->moduleName() );
            }
            Smoke::Index methodId = mi.smoke->methodMaps[mi.index].method;
            if ( !methodId ) {
                croak( "Corrupt method %s::%s", classname, methodname );
            }
            else if ( methodId > 0 ) {     // single match
                XPUSHs( sv_2mortal(alloc_perl_moduleindex(smokeId, methodId)) );
            }
            else {                  // multiple match
                // trun into ambiguousMethodList index
                methodId = -methodId;

                // Put all ambiguous method possibilities onto the stack
                while( mi.smoke->ambiguousMethodList[methodId] ) {
                    XPUSHs( 
                        sv_2mortal(
                            alloc_perl_moduleindex(smokeId, (IV)mi.smoke->ambiguousMethodList[methodId])
                        )
                    );
                    ++methodId;
                }
            }
        }

#// Args: none
#// Returns: an array of all classes that qtcore_Smoke knows about
SV*
getClassList()
    CODE:
        AV* av = newAV();
        for (int i = 1; i <= qtcore_Smoke->numClasses; i++) {
            av_push(av, newSVpv(qtcore_Smoke->classes[i].className, 0));
        }
        RETVAL = newRV_noinc((SV*)av);
    OUTPUT:
        RETVAL

#// args: none
#// returns: an array of all enum names that qtcore_Smoke knows about
SV*
getEnumList()
    CODE:
        AV *av = newAV();
        for(int i = 1; i < qtcore_Smoke->numTypes; i++) {
            Smoke::Type curType = qtcore_Smoke->types[i];
            if( (curType.flags & Smoke::tf_elem) == Smoke::t_enum )
                av_push(av, newSVpv(curType.name, 0));
        }
        RETVAL = newRV_noinc((SV*)av);
    OUTPUT:
        RETVAL

#// Args: int classId: a smoke classId
#// Returns: An array of strings defining the inheritance list for that class.
void
getIsa( moduleId )
        SV* moduleId
    PPCODE:
        AV* av = (AV*)SvRV(moduleId);
        SV** smokeId = av_fetch(av, 0, 0);
        SV** classId = av_fetch(av, 1, 0);
        Smoke* smoke = smokeList[SvIV(*smokeId)];
        Smoke::Index *parents =
            smoke->inheritanceList +
            smoke->classes[SvIV(*classId)].parents;
        while(*parents)
            XPUSHs(sv_2mortal(newSVpv(smoke->classes[*parents++].className, 0)));

#// Args: methodId: a smoke method id
#//       argnum: the argument number to query
#// Returns: the c++ type of the n'th argument of methodId's associated method
char*
getTypeNameOfArg( smokeId, methodId, argnum )
        int smokeId
        int methodId
        int argnum
    CODE:
        Smoke* smoke = smokeList[smokeId];
        Smoke::Method &method = smoke->methods[methodId];
        Smoke::Index* args = smoke->argumentList + method.args;
        RETVAL = (char*)smoke->types[args[argnum]].name;
    OUTPUT:
        RETVAL

SV*
getNativeMetaObject( smokeId, methodId )
        int smokeId
        int methodId
    CODE:
        smokeperl_object* nothis = alloc_smokeperl_object( false, 0, 0, 0 );
        Smoke* smoke = smokeList[smokeId];
        PerlQt4::MethodCall call(
            smoke,
            methodId,
            nothis,
            0,
            0
        );
        call.next();
        RETVAL = call.var();
    OUTPUT:
        RETVAL

#// Args: int classId: a smoke classId
#// Returns: The number of arguments that method has
int
getNumArgs( smokeId, methodId )
        int smokeId
        int methodId
    CODE:
        Smoke::Method &method = smokeList[smokeId]->methods[methodId];
        RETVAL = method.numArgs;
    OUTPUT:
        RETVAL

const char*
getSVt( sv )
        SV* sv
    CODE:
        RETVAL = get_SVt(sv);
    OUTPUT:
        RETVAL

#// Args: char* name: the c++ name of a Qt4 class
#// Returns: An array where the first element is the smoke classId for that
#// class, and the second element is the index into the list of smoke objects.
void
findClass( name )
        char* name
    PPCODE:
        Smoke::ModuleIndex mi = qtcore_Smoke->findClass(name);
        EXTEND(SP, 2);
        PUSHs(sv_2mortal(newSViv(mi.index)));
        PUSHs(sv_2mortal(newSViv(smokeList.indexOf(mi.smoke))));

#// Args: char* name: the c++ name of a Qt4 class
#// Returns: the smoke classId for that Qt4 class
const char*
classFromId( classId )
        int classId
    CODE:
        RETVAL = qtcore_Smoke->classes[classId].className;
    OUTPUT:
        RETVAL

int
debug()
    CODE:
        RETVAL = do_debug;
    OUTPUT:
        RETVAL

#// Args: char* package: the name of a Perl package
#// Returns: none
#// Desc: Makes calls to undefined subroutines for the given package redirect
#//       to call XS_AUTOLOAD
void
installautoload( package )
        char* package
    CODE:
        if(!package) XSRETURN_EMPTY;
        char* autoload = new char[strlen(package) + 11];
        sprintf(autoload, "%s::_UTOLOAD", package);
        newXS(autoload, XS_AUTOLOAD, __FILE__);
        delete[] autoload;

void
installqt_metacall(package)
        char *package
    CODE:
        if(!package) XSRETURN_EMPTY;
        char *qt_metacall = new char[strlen(package) + 14];
        strcpy(qt_metacall, package);
        strcat(qt_metacall, "::qt_metacall");
        newXS(qt_metacall, XS_qt_metacall, __FILE__);
        delete[] qt_metacall;

void
installsignal(signalname)
        char *signalname
    CODE:
        if(!signalname) XSRETURN_EMPTY;
        newXS(signalname, XS_signal, __FILE__);

void
installthis( package )
        char* package
    CODE:
        if( !package ) XSRETURN_EMPTY;
        char* attr = new char[strlen(package) + 7];
        strcpy(attr, package);
        strcat(attr, "::this");
        // *{ $name } = sub () : lvalue;
        CV *attrsub = newXS(attr, XS_this, __FILE__);
        sv_setpv((SV*)attrsub, ""); // sub this () : lvalue; perldoc perlsub
        delete[] attr;

SV*
make_metaObject(parentModuleId,parentMeta,stringdata_sv,data_sv)
        SV* parentModuleId
        SV* parentMeta
        SV* stringdata_sv
        SV* data_sv
    CODE:
        // Get the meta object of the super class, to inherit the super's
        // sig/slots
        QMetaObject* superdata;
        if( SvROK(parentMeta) ){
            // The parent class is a custom Perl class whose metaObject
            // was constructed at runtime
            superdata = (QMetaObject*)sv_obj_info(parentMeta)->ptr;
        }
        else {
            // The parent class is a Smoke class, so call metaObject() on the
            // instance to get it via a smoke library call
            //const char* classname = qtcore_Smoke->classes[SvIV(parentClassId)].className;
            //Smoke::Index methodId = getMethod(qtcore_Smoke, classname, "metaObject");
            Smoke::ModuleIndex nameMId = qtcore_Smoke->idMethodName("staticMetaObject");
            Smoke* parentClassSmoke = smokeList[SvIV(*(SV**)av_fetch((AV*)SvRV(parentModuleId), 0, 0))];
            Smoke::Index parentClassId = SvIV(*(SV**)av_fetch((AV*)SvRV(parentModuleId), 1, 0));
            Smoke::ModuleIndex classMId( parentClassSmoke, parentClassId );
            Smoke::ModuleIndex meth = parentClassSmoke->findMethod(classMId, nameMId);
            if (meth.index > 0) {
                Smoke::Method &m = meth.smoke->methods[meth.smoke->methodMaps[meth.index].method];
                Smoke::ClassFn fn = meth.smoke->classes[m.classId].classFn;
                Smoke::StackItem args[1];
                (*fn)(m.method, 0, args);
                superdata = (QMetaObject*) args[0].s_voidp;
            }
            else {
                // Should never happen...
                croak( "Cannot find %s::metaObject() method\n",
                       meth.smoke->classes[parentClassId].className );
            }
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
        STRLEN len = SvLEN(stringdata_sv);
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
        o.smoke = qtcore_Smoke;
        o.classId = qtcore_Smoke->idClass("QMetaObject").index,
        o.ptr = meta;
        o.allocated = true;

        HV *hv = newHV();
        RETVAL = newRV_noinc((SV*)hv);
        sv_bless( RETVAL, gv_stashpv( " Qt4::MetaObject", TRUE ) );
        sv_magic((SV*)hv, 0, '~', (char*)&o, sizeof(o));
        //Not sure we need the entry in the pointer_map
        mapPointer(RETVAL, &o, pointer_map, o.classId, 0);
    OUTPUT:
        RETVAL

bool
isObject(obj)
        SV* obj
    CODE:
        RETVAL = sv_obj_info(obj) ? TRUE : FALSE;
    OUTPUT:
        RETVAL

void
setDebug(channel)
        int channel
    CODE:
        do_debug = channel;

void
setQApp( qapp )
        SV* qapp
    CODE:
        if( SvROK( qapp ) )
            sv_setsv_mg( sv_qapp, qapp );

void
setThis(obj)
        SV* obj
    CODE:
        sv_setsv_mg( sv_this, obj );

void*
sv_to_ptr(sv)
    SV* sv

MODULE = Qt4                PACKAGE = Qt4                

PROTOTYPES: ENABLE

SV*
this()
    CODE:
        RETVAL = newSVsv(sv_this);
    OUTPUT:
        RETVAL

SV*
qApp()
    CODE:
        if (!sv_qapp)
            RETVAL = &PL_sv_undef;
        else
            RETVAL = newSVsv(sv_qapp);
    OUTPUT:
        RETVAL

MODULE = QtCore4            PACKAGE = QtCore4

BOOT:
    /* same as -DUSE_SAFE_PUTENV in compile. prevents a "free from wrong
     * pool during global destruction" error with debugperl; and a segfault
     * otherwise (due to invalid free)
     *
     * see also:
     * http://www.nntp.perl.org/group/perl.perl5.porters/2008/06/msg137726.html
     * http://www.qtsoftware.com/developer/task-tracker/index_html?id=217782&method=entry
     */
#ifndef PERL_USE_SAFE_PUTENV
    PL_use_safe_putenv = 1;
#endif

    init_qtcore_Smoke();
    smokeList << qtcore_Smoke;

    binding = PerlQt4::Binding(qtcore_Smoke);
    PerlQt4Module module = { "PerlQtCore4", resolve_classname_qt, 0, &binding };
    perlqt_modules[qtcore_Smoke] = module;

    install_handlers(Qt4_handlers);

    pointer_map = get_hv( "Qt4::_internal::pointer_map", FALSE );

    newXS("Qt4::qVariantFromValue", XS_qvariant_from_value, __FILE__);
    newXS("Qt4::qVariantValue", XS_qvariant_value, __FILE__);
    newXS(" Qt4::Object::findChildren", XS_find_qobject_children, __FILE__);
    newXS("Qt4::Object::findChildren", XS_find_qobject_children, __FILE__);
    newXS("Qt4::Object::qobject_cast", XS_qobject_qt_metacast, __FILE__);
    newXS(" Qt4::AbstractItemModel::columnCount", XS_qabstract_item_model_columncount, __FILE__);
    newXS(" Qt4::AbstractItemModel::data", XS_qabstract_item_model_data, __FILE__);
    newXS(" Qt4::AbstractItemModel::insertColumns", XS_qabstract_item_model_insertcolumns, __FILE__);
    newXS(" Qt4::AbstractItemModel::insertRows", XS_qabstract_item_model_insertrows, __FILE__);
    newXS(" Qt4::AbstractItemModel::removeColumns", XS_qabstract_item_model_removecolumns, __FILE__);
    newXS(" Qt4::AbstractItemModel::removeRows", XS_qabstract_item_model_removerows, __FILE__);
    newXS(" Qt4::AbstractItemModel::rowCount", XS_qabstract_item_model_rowcount, __FILE__);
    newXS(" Qt4::AbstractItemModel::setData", XS_qabstract_item_model_setdata, __FILE__);
    newXS(" Qt4::ModelIndex::internalPointer", XS_qmodelindex_internalpointer, __FILE__);

    sv_this = newSV(0);
    sv_qapp = newSV(0);
