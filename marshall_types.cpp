#include "marshall_types.h"
#include "handlers.h"

extern SV* sv_this;

namespace PerlQt {

    MethodReturnValueBase::MethodReturnValueBase(Smoke *smoke, Smoke::Index methodIndex, Smoke::Stack stack) :
	_smoke(smoke), _methodIndex(methodIndex), _stack(stack) {
    }

    const Smoke::Method &MethodReturnValueBase::method() {
        return _smoke->methods[_methodIndex];
    }

    Smoke::StackItem &MethodReturnValueBase::item() {
        return _stack[0];
    }

    Smoke *MethodReturnValueBase::smoke() {
        return _smoke;
    }

    SmokeType MethodReturnValueBase::type() {
        return SmokeType(_smoke, method().ret);
    }

    void MethodReturnValueBase::next() {
    }

    bool MethodReturnValueBase::cleanup() {
        return false;
    }

    void MethodReturnValueBase::unsupported() {
        croak("Cannot handle '%s' as return-type of %s::%s",
            type().name(),
            _smoke->className(method().classId),
            _smoke->methodNames[method().name]);
    }

    SV* MethodReturnValueBase::var() {
        return _retval;
    }

    //------------------------------------------------

    VirtualMethodReturnValue::VirtualMethodReturnValue(Smoke *smoke, Smoke::Index methodIndex, Smoke::Stack stack, SV *retval) :
      MethodReturnValueBase(smoke, methodIndex, stack) {
        _retval = retval;
        Marshall::HandlerFn fn = getMarshallFn(type());
        (*fn)(this);
    }
    
    Marshall::Action VirtualMethodReturnValue::action() {
        return Marshall::FromSV;
    }

    //------------------------------------------------

    MethodReturnValue::MethodReturnValue(Smoke *smoke, Smoke::Index methodIndex, Smoke::Stack stack) :
      MethodReturnValueBase(smoke, methodIndex, stack)  {
        _retval = newSV(0);
        Marshall::HandlerFn fn = getMarshallFn(type());
        (*fn)(this);
    }

    // We're passing an SV back to perl
    Marshall::Action MethodReturnValue::action() {
        return Marshall::ToSV;
    }

    //------------------------------------------------

    MethodCallBase::MethodCallBase(Smoke *smoke, Smoke::Index meth) :
        _smoke(smoke), _method(meth), _cur(-1), _called(false), _sp(0)  
    {  
    }

    MethodCallBase::MethodCallBase(Smoke *smoke, Smoke::Index meth, Smoke::Stack stack) :
        _smoke(smoke), _method(meth), _stack(stack), _cur(-1), _called(false), _sp(0) 
    {  
    }

    Smoke *MethodCallBase::smoke() { 
        return _smoke; 
    }

    SmokeType MethodCallBase::type() { 
        return SmokeType(_smoke, _args[_cur]); 
    }

    Smoke::StackItem &MethodCallBase::item() { 
        return _stack[_cur + 1]; 
    }

    const Smoke::Method &MethodCallBase::method() { 
        return _smoke->methods[_method]; 
    }

    void MethodCallBase::next() {
        int oldcur = _cur;
        _cur++;
        while( _cur < items() ) {
            Marshall::HandlerFn fn = getMarshallFn(type());
            (*fn)(this);
            _cur++;
        }

        callMethod();
        _cur = oldcur;
    }

    void MethodCallBase::unsupported() {
        croak("Cannot handle '%s' as argument of virtual method %s::%s",
                type().name(),
                _smoke->className(method().classId),
                _smoke->methodNames[method().name]);
    }

    const char* MethodCallBase::classname() {
        return _smoke->className(method().classId);
    }

    //------------------------------------------------

    VirtualMethodCall::VirtualMethodCall(Smoke *smoke, Smoke::Index meth, Smoke::Stack stack, SV *obj, GV *gv) :
      MethodCallBase(smoke,meth,stack), _gv(gv){
        dSP;
        ENTER;
        SAVETMPS;
        PUSHMARK(SP);
        EXTEND(SP, items());
        _savethis = sv_this;
        sv_this = newSVsv(obj);
        _sp = SP + 1;
        for(int i = 0; i < items(); i++)
            _sp[i] = sv_newmortal();
        _args = _smoke->argumentList + method().args;
    }

    VirtualMethodCall::~VirtualMethodCall() {
        SvREFCNT_dec(sv_this);
        sv_this = _savethis;
    }

    Marshall::Action VirtualMethodCall::action() {
        return Marshall::ToSV;
    }

    SV *VirtualMethodCall::var() {
        return _sp[_cur];
    }

    int VirtualMethodCall::items() {
        return method().numArgs;
    }

    void VirtualMethodCall::callMethod() {
        if (_called) return;
        _called = true;

        // This is the stack pointer we'll pass to the perl call
        dSP;
        // This defines how many arguments we're sending to the perl sub
        SP = _sp + items() - 1;
        PUTBACK;
        // Call the perl sub
        call_sv((SV*)GvCV(_gv), G_SCALAR);
        // Get the stack the perl sub returned
        SPAGAIN;
        // Marshall the return value back to c++, using the top of the stack
        VirtualMethodReturnValue r(_smoke, _method, _stack, POPs);
        PUTBACK;
        FREETMPS;
        LEAVE;
    }

    bool VirtualMethodCall::cleanup() {
        return false;
    }

    //------------------------------------------------

    MethodCall::MethodCall(Smoke *smoke, Smoke::Index method, smokeperl_object *call_this, SV **sp, int items):
      MethodCallBase(smoke,method), _this(call_this), _sp(sp), _items(items) {
        _stack = new Smoke::StackItem[items + 1];
        _args = _smoke->argumentList + _smoke->methods[_method].args;
        _retval = newSV(0);
    }

    MethodCall::~MethodCall() {
        delete[] _stack;
    }

    Marshall::Action MethodCall::action() {
        return Marshall::FromSV;
    }

    SV *MethodCall::var() {
        if(_cur < 0)
            return _retval;
        return *(_sp + _cur);
    }

    int MethodCall::items() {
        return _items;
    }

    bool MethodCall::cleanup() {
        return true;
    }

    const char *MethodCall::classname() {
        return MethodCallBase::classname();
    }
}
