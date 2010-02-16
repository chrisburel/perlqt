#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <stdio.h>
#include <stdlib.h>

#include "smoke.h"
#include "QtSimple.h"
#include "marshall.h"
#include "smokeperl.h"
#include "handlers.h"

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

char *myargv = "Hello";
int myargc = 1;
QApplication *qapp = new QApplication(myargc, &myargv);

QHash<Smoke*, PerlQtModule> perlqt_modules;
static PerlQt::Binding binding;

class MethodReturnValue : public Marshall {
    Smoke *_smoke;
    Smoke::Index _methodIndex;
    Smoke::Stack _stack;
    SV *_retval;
public:
    MethodReturnValue(Smoke *smoke, Smoke::Index methodIndex, Smoke::Stack stack) :
      _smoke(smoke), _methodIndex(methodIndex), _stack(stack)  {
        _retval = newSV(0);
        Marshall::HandlerFn fn = getMarshallFn(type());
        (*fn)(this);
    }

    SmokeType type() { return SmokeType(_smoke, method().ret); }

    // We're passing an SV back to perl
    Marshall::Action action() { return Marshall::ToSV; }
    Smoke::StackItem &item() { return _stack[0]; }
    SV *var() { return _retval; }

    void unsupported() {
        croak("Cannot handle '%s' as return-type of %s::%s",
            type().name(),
            _smoke->className(method().classId),
            _smoke->methodNames[method().name]);
    }

	Smoke *smoke() { return _smoke; }
    void next() {}
    bool cleanup() { return false; }

    Smoke::Method &method() {
        return _smoke->methods[_methodIndex];
    }
};

class MethodCall : public Marshall {
    Smoke *_smoke;
    int _curArgIndex;
    Smoke::Stack _stack;
    Smoke::Index _methodIndex;
    smokeperl_object *_this;
    Smoke::Index *_args;
    SV **_sp;
    SV *_retval;
    int _items;

    void _castArgs() {
        int oldArgIndex = _curArgIndex;
        _curArgIndex++; // Start at 0
        while( _curArgIndex < _items ) {
            // We need to know the datatype of each argument
            Marshall::HandlerFn fn = getMarshallFn(type());
            (*fn)(this); // Modifies _stack
            _curArgIndex++;
        }

        _curArgIndex = oldArgIndex;
    }

public:
    MethodCall(Smoke *smoke, Smoke::Index methodIndex, smokeperl_object *call_this, SV **sp, int items):
      _smoke(smoke), _curArgIndex(-1), _methodIndex(methodIndex), _this(call_this), _sp(sp), _items(items) {
        _stack = new Smoke::StackItem[items + 1];
        _args = _smoke->argumentList + _smoke->methods[_methodIndex].args;
        _retval = newSV(0);
    }

    ~MethodCall() {
        delete[] _stack;
    }

    // Returns the data type of the incoming argument(s)
    SmokeType type() { return SmokeType(_smoke, _args[_curArgIndex]); }

    // We're converting from an SV from perl
    Marshall::Action action() { return Marshall::FromSV; }

    Smoke::StackItem &item() { return _stack[_curArgIndex + 1]; }

    SV *var() {
        if(_curArgIndex < 0)
            return _retval;
        return *(_sp + _curArgIndex);
    }

    void unsupported() { 
        croak("Cannot handle '%s' as argument to %s::%s",
            type().name(),
            _smoke->className(method().classId),
            _smoke->methodNames[method().name]);
    }

    Smoke *smoke() { return _smoke; };

	void next() {
        // Marshall incoming arguments
		_castArgs();
		callMethod();
	}

    bool cleanup() { return true; }

    inline const Smoke::Method &method() {
        return _smoke->methods[_methodIndex];
    }

    void callMethod() {
        Smoke::Method *method = _smoke->methods + _methodIndex;
        Smoke::ClassFn fn = _smoke->classes[method->classId].classFn;

        void *ptr = _smoke->cast(
            _this->ptr,
            _this->classId,
            _smoke->methods[_methodIndex].classId
        );

        // Call the method
        (*fn)(method->method, ptr, _stack);

        // Tell the method call what binding to use
        if (method->flags & Smoke::mf_ctor) {
            Smoke::StackItem s[2];
            s[1].s_voidp = perlqt_modules[_smoke].binding;
            (*fn)(0, _stack[0].s_voidp, s);
        }

        // Marshall the return value
        MethodReturnValue callreturn( _smoke, _methodIndex, _stack );

        // Save the result
        _retval = callreturn.var();
    }
};

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
    HV* classcache_ext = get_hv( "QtSimple::_internal::package2classid", false);
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

XS(XS_QtSimple__myQTableView_setRootIndex){
    dXSARGS;
    fprintf( stderr, "In XS Custom   for setRootIndex\n" );
    
    char *classname = "QTableView";
    char *methodname = "setRootIndex#";

    Smoke::StackItem args[items + 1];
    args[1].s_voidp = sv_obj_info( ST(1) )->ptr;

    Smoke::Index methodIndex = getMethod(qt_Smoke, classname, methodname );

    MethodCall call( qt_Smoke, methodIndex, sv_obj_info(ST(0)), SP - items + 2, items - 1 );
    call.next();

    SV* retval = call.var();

    // Put the return value onto perl's stack
    ST(0) = sv_2mortal(retval);
    XSRETURN(1);
}

XS(XS_AUTOLOAD){
    dXSARGS;
    SV *autoload = get_sv("QtSimple::AutoLoad::AUTOLOAD", TRUE);
    char *package = SvPV_nolen(autoload);
    fprintf(stderr, "In XS Autoload for %s\n", SvPV_nolen( autoload ));
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
    if(withObject) {
        package++;
    }

    Smoke::Index classid = package_classid(package);
    char *classname = (char*)qt_Smoke->className(classid);

    // Look to see if there's a perl subroutine for this method
    HV* classcache_ext = get_hv( "QtSimple::_internal::package2classid", false);
    U32 klen = strlen( package );
    SV** classcache = hv_fetch( classcache_ext, package, klen, 0 );
    if( !classcache ) {
        HV *stash = gv_stashpv(package, TRUE);
        GV *gv = gv_fetchmethod_autoload(stash, methodname, 0);

        if(gv){
            // Call the found method
            ENTER;
            SAVETMPS;
            PUSHMARK(SP - items + withObject);
            // What context are we calling this subroutine in?
            I32 gimme = GIMME_V;
            int count = call_sv((SV*)GvCV(gv), gimme|G_EVAL);
            PUTBACK;
            FREETMPS;
            LEAVE;
            XSRETURN(count);
        }
    }
    else if(!strcmp(methodname, "DESTROY")) {
        //fprintf( stderr, "DESTROY: coming soon.\n" );
    }
    else {
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
            call_this = sv_obj_info( ST(0) );
        }
        else{
            call_this = &temp;
        }

        Smoke::Index methodid = getMethod(qt_Smoke, classname, methodname );

        // We need current_object, methodid, and args to call the method
        MethodCall call( qt_Smoke,
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

MODULE = QtSimple   PACKAGE = QtSimple::_internal

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

MODULE = QtSimple   PACKAGE = QtSimple

PROTOTYPES: DISABLE

int
appexec()
    CODE:
        RETVAL = qapp->exec();
    OUTPUT:
        RETVAL

BOOT:
    init_qt_Smoke();
    //qt_Smoke->binding = new MySmokeBinding(qt_Smoke);
    binding = PerlQt::Binding(qt_Smoke);
    PerlQtModule module = { "PerlQt", &binding };
    perlqt_modules[qt_Smoke] = module;

    install_handlers(Qt_handlers);
    //newXS(" QtSimple::QTableView::setRootIndex", XS_QtSimple__myQTableView_setRootIndex, file);
