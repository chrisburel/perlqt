#include "marshall_types.h"
#include "handlers.h"

extern SV* sv_this;

void
smokeStackFromQtStack(Smoke::Stack stack, void ** _o, int start, int end, QList<MocArgument*> args)
{
	for (int i = start, j = 0; i < end; i++, j++) {
		void *o = _o[j];
		switch(args[i]->argType) {
		case xmoc_bool:
			stack[j].s_bool = *(bool*)o;
			break;
		case xmoc_int:
			stack[j].s_int = *(int*)o;
			break;
		case xmoc_uint:
			stack[j].s_uint = *(uint*)o;
			break;
		case xmoc_long:
			stack[j].s_long = *(long*)o;
			break;
		case xmoc_ulong:
			stack[j].s_ulong = *(ulong*)o;
			break;
		case xmoc_double:
			stack[j].s_double = *(double*)o;
			break;
		case xmoc_charstar:
			stack[j].s_voidp = o;
			break;
		case xmoc_QString:
			stack[j].s_voidp = o;
			break;
		default:	// case xmoc_ptr:
		{
			const SmokeType &t = args[i]->st;
			void *p = o;
			switch(t.elem()) {
			case Smoke::t_bool:
			stack[j].s_bool = **(bool**)o;
			break;
			case Smoke::t_char:
			stack[j].s_char = **(char**)o;
			break;
			case Smoke::t_uchar:
			stack[j].s_uchar = **(unsigned char**)o;
			break;
			case Smoke::t_short:
			stack[j].s_short = **(short**)p;
			break;
			case Smoke::t_ushort:
			stack[j].s_ushort = **(unsigned short**)p;
			break;
			case Smoke::t_int:
			stack[j].s_int = **(int**)p;
			break;
			case Smoke::t_uint:
			stack[j].s_uint = **(unsigned int**)p;
			break;
			case Smoke::t_long:
			stack[j].s_long = **(long**)p;
			break;
			case Smoke::t_ulong:
			stack[j].s_ulong = **(unsigned long**)p;
			break;
			case Smoke::t_float:
			stack[j].s_float = **(float**)p;
			break;
			case Smoke::t_double:
			stack[j].s_double = **(double**)p;
			break;
			case Smoke::t_enum:
			{
				//Smoke::EnumFn fn = SmokeClass(t).enumFn();
                Smoke::Class* _c = t.smoke()->classes + t.classId();
                Smoke::EnumFn fn = _c->enumFn;
				if (!fn) {
					croak("Unknown enumeration %s\n", t.name());
					stack[j].s_enum = **(int**)p;
					break;
				}
				Smoke::Index id = t.typeId();
				(*fn)(Smoke::EnumToLong, id, p, stack[j].s_enum);
			}
			break;
			case Smoke::t_class:
			case Smoke::t_voidp:
				if (strchr(t.name(), '*') != 0) {
					stack[j].s_voidp = *(void **)p;
				} else {
					stack[j].s_voidp = p;
				}
			break;
			}
		}
		}
	}
}

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

    //------------------------------------------------

    // The steps are:
    // Copy Qt stack to Smoke Stack
    // use next() to marshall the smoke stack
    // callMethod()
    // The rest is modeled after the VirtualMethodCall
    InvokeSlot::InvokeSlot(SV* call_this, char* methodname, QList<MocArgument*> args, void** a) :
      _cur(-1), _called(false), _methodname(methodname), _this(call_this), _a(a) {
        _items = args.count();
        _args = args;
        _stack = new Smoke::StackItem[_items - 1];
        dSP;
        ENTER;
        SAVETMPS;
        PUSHMARK(SP);
        EXTEND(SP, _items);
        _sp = SP + 1;
        for(int i = 0; i < _items-1; i++)
            _sp[i] = sv_newmortal();
        copyArguments();
    }

    InvokeSlot::~InvokeSlot() {
        delete[] _stack;
    }

    Smoke *InvokeSlot::smoke() {
        return type().smoke();
    }

    Marshall::Action InvokeSlot::action() {
        return Marshall::ToSV;
    }

    const MocArgument& InvokeSlot::arg() {
        return *(_args[_cur + 1]);
    }

    SmokeType InvokeSlot::type() {
        return arg().st;
    }

    Smoke::StackItem &InvokeSlot::item() {
        return _stack[_cur];
    }

    SV* InvokeSlot::var() {
        return _sp[_cur];
    }

    void InvokeSlot::callMethod() {
        //Call the perl sub
        //Copy the way the VirtualMethodCall does it
        HV *stash = SvSTASH(SvRV(_this));
        if(*HvNAME(stash) == ' ' ) // if withObject, look for a diff stash
            stash = gv_stashpv(HvNAME(stash) + 1, TRUE);

        GV *gv = gv_fetchmethod_autoload(stash, _methodname, 0);
        if(!gv) {
            fprintf( stderr, "Found no method to call in slot\n" );
            return;
        }

        dSP;
        SP = _sp + _items - 1;
        PUTBACK;
        call_sv((SV*)GvCV(gv), G_VOID);
    }

    void InvokeSlot::next() {
        int oldcur = _cur;
        _cur++;
        while( _cur < _items - 1 ) {
            Marshall::HandlerFn fn = getMarshallFn(type());
            (*fn)(this);
            _cur++;
        }

        callMethod();
        _cur = oldcur;
    }

    void InvokeSlot::unsupported() {
        croak("Cannot handle '%s' as argument of slot call",
              type().name() );
    }

    bool InvokeSlot::cleanup() {
        return false;
    }

    void InvokeSlot::copyArguments() {
        smokeStackFromQtStack( _stack, _a + 1, 1, _items, _args );
    }
}
