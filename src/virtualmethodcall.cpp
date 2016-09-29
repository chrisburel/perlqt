#include <iostream>
#include "virtualmethodcall.h"

namespace SmokePerl {

VirtualMethodCall::ReturnValue::ReturnValue(Smoke::ModuleIndex methodId, Smoke::Stack stack, SV* returnValue) :
    m_methodId(methodId), m_stack(stack), m_returnValue(returnValue) {

    Marshall::HandlerFn fn = getMarshallFn(type());
    (*fn)(this);
}

void VirtualMethodCall::ReturnValue::unsupported() const {
    croak("Unsupported type %s", type().name());
}

VirtualMethodCall::VirtualMethodCall(Smoke::ModuleIndex methodId, Smoke::Stack stack, SV* self, GV* gv) :
    m_methodId(methodId), m_stack(stack), m_self(self), m_current(-1),
    m_called(false), m_methodRef(methodId.smoke->methods[methodId.index]),
    m_gv(gv) {

    dSP;
    ENTER;
    SAVETMPS;
    PUSHMARK(SP);
    // Reserve space on the stack for our arguments.  Remember to make space
    // for $self
    EXTEND(SP, m_methodRef.numArgs + 1);

    m_argv = SP + 1;
    for (int i = 0; i < m_methodRef.numArgs + 1; ++i)
        m_argv[i] = sv_newmortal();
    // Put $self in @_
    sv_setsv(m_argv[0], self);

    m_args = m_methodId.smoke->argumentList + m_methodRef.args;
}

VirtualMethodCall::~VirtualMethodCall() {
}

void VirtualMethodCall::unsupported() const {
    croak("Unsupported type %s", type().name());
}


void VirtualMethodCall::callMethod() {
    if (m_called)
        return;
    m_called = true;

    // Set up the stack pointer
    dSP;
    SP = m_argv + m_methodRef.numArgs;
    PUTBACK;

    // Call the method in scalar context
    I32 callFlags = G_SCALAR;
    call_sv((SV*)GvCV(m_gv), callFlags);

    // Refresh the stack pointer, it moved after the subroutine call
    SPAGAIN;

    // Marshall the return value
    ReturnValue result(m_methodId, m_stack, POPs);

    PUTBACK;
    FREETMPS;
    LEAVE;
}

void VirtualMethodCall::next() {
    int previous = m_current;
    ++m_current;

    while (!m_called && m_current < m_methodRef.numArgs) {
        Marshall::HandlerFn fn = getMarshallFn(type());
        (*fn)(this);
        ++m_current;
    }
    callMethod();
    m_current = previous;
}

}
