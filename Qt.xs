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
#include "handlers.h"
#include "marshall_types.h"

#ifdef do_open
#undef do_open
#endif

#ifdef do_close
#undef do_close
#endif
#include "Qt/qapplication.h"
#include "QtCore/QHash"

extern Q_DECL_EXPORT Smoke *qt_Smoke;
extern Q_DECL_EXPORT void init_qt_Smoke();
extern TypeHandler Qt_handlers[];

SV *sv_this = 0;
HV *pointer_map = 0;

char *myargv = "Hello";
int myargc = 1;
QApplication *qapp = new QApplication(myargc, &myargv);

QHash<Smoke*, PerlQtModule> perlqt_modules;
static PerlQt::Binding binding;

namespace PerlQt {
Binding::Binding() : SmokeBinding(0) {};
Binding::Binding(Smoke *s) : SmokeBinding(s) {};

void Binding::deleted(Smoke::Index classId, void *ptr) {
    // Ignore deletion
}

bool Binding::callMethod(Smoke::Index method, void *ptr, Smoke::Stack args, bool isAbstract) {
    // Look for a perl sv associated with this pointer
    SV *obj = getPointerObject(ptr);
    smokeperl_object *o = sv_obj_info(obj);

    // Didn't find one
    if(!o) {
        if(!PL_dirty) // If not in global destruction
            fprintf(stderr, "Cannot find object for virtual method\n");
        return false;
    }

    // Now find the stash for this perl object
    HV *stash = SvSTASH(SvRV(obj));
    if(*HvNAME(stash) == ' ') // if withObject, look for a diff stash
        stash = gv_stashpv(HvNAME(stash) + 1, TRUE);

    // Get the name of the method being called
    const char *methodname = smoke->methodNames[smoke->methods[method].name];
    // Look up the autoload subroutine for that method
    GV *gv = gv_fetchmethod_autoload(stash, methodname, 0);
    // Found no autoload function
    if(!gv) return false;

    fprintf(stderr, "In Virtual for %s\n", methodname);

    VirtualMethodCall call(smoke, method, args, obj, gv);
    call.next();
    return true;
}

char* Binding::className(Smoke::Index classId) {
    const char *className = smoke->className(classId);
    char *buf = new char[strlen(className) + 12];
    strcpy(buf, " Qt::");
    strcat(buf, className);
    return buf;
}
} // End namespace PerlQt

Smoke::Index getMethod(Smoke *smoke, const char* c, const char* m) {
    Smoke::Index method = smoke->findMethod(c, m).index;
    Smoke::Index i = smoke->methodMaps[method].method;
    if(i <= 0) {
        // ambiguous method have i < 0; it's possible to resolve them, see the other bindings
        fprintf(stderr, "%s method %s::%s\n",
            i ? "Ambiguous" : "Unknown", c, m);
        exit(-1);
    }
    return i;
}

void callMethod(Smoke *smoke, void *obj, Smoke::Index method, Smoke::Stack args) {
    Smoke::Method *m = smoke->methods + method;
    Smoke::ClassFn fn = smoke->classes[m->classId].classFn;
    fn(m->method, obj, args);
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
    strcpy(nisa, package);
    strcat(nisa, "::ISA");
    AV* isa=get_av(nisa, true);

    // Loop over the ISA array
    //fprintf( stderr, "ISA contains %d entries for %s\n", av_len(isa), nisa );
    delete[] nisa;
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
    for(Smoke::Index *i = o->smoke->inheritanceList + o->smoke->classes[classId].parents;
        *i;
        i++) {
        mapPointer(obj, o, hv, *i, lastptr);
    }
}

void unmapPointer(smokeperl_object *o, Smoke::Index classId, void *lastptr) {

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
    fprintf(stderr, "In XS Autoload for %s::%s\n", package, methodname);

    // Look to see if there's a perl subroutine for this method
    // HV* classcache_ext = get_hv( "Qt::_internal::package2classid", false);
    // U32 klen = strlen( package );
    // SV** classcache = hv_fetch( classcache_ext, package, klen, 0 );
    // if( !classcache ) {
        HV *stash = gv_stashpv(package, TRUE);
        GV *gv = gv_fetchmethod_autoload(stash, methodname, 0);

        if(gv){
            fprintf(stderr, "\tfound in %s's Perl stash\n", package);

            SV *old_this;
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
    // }
    else if(!strcmp(methodname, "DESTROY")) {
        //fprintf( stderr, "DESTROY: coming soon.\n" );
    }
    else {
        Smoke::Index classid = package_classid(package);
        char *classname = (char*)qt_Smoke->className(classid);

        // Loop over the arguments and see what kind we have
        for(int i = 0 + withObject; i < items; i++) {
            SV* arg = ST(i);
            if( sv_obj_info( arg ) ){
                strcat( methodname, "#" );
            }
            else if( SvROK(arg) ) {
                strcat( methodname, "?" );
            }
            else if( SvIOK(arg) || SvNOK(arg) || SvPOK(arg) ){
                strcat( methodname, "$" );
            }
        }

        smokeperl_object temp = { 0, 0, 0, false };
        smokeperl_object *call_this;
        if( withObject ){
            if( isSuper ){
                call_this = sv_obj_info( sv_this );
            }
            else {
                call_this = sv_obj_info( ST(0) );
            }
        }
        else{
            call_this = &temp;
        }

        Smoke::Index methodid;
        if(!strcmp(methodname, "QVariant$")){
            methodid = 18373;
        }
        else {
            methodid = getMethod(qt_Smoke, classname, methodname );
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

int
appexec()
    CODE:
        fprintf( stderr, "In QApplication::exec\n" );
        RETVAL = qapp->exec();
    OUTPUT:
        RETVAL

BOOT:
    init_qt_Smoke();
    binding = PerlQt::Binding(qt_Smoke);
    PerlQtModule module = { "PerlQt", &binding };
    perlqt_modules[qt_Smoke] = module;

    install_handlers(Qt_handlers);
    sv_this = newSV(0);
    pointer_map = newHV();
    //newXS(" Qt::QTableView::setRootIndex", XS_Qt__myQTableView_setRootIndex, file);
