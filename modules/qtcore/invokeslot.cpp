#include <QMetaMethod>

#include "qtcore_smoke.h"
#include "smokeobject.h"
#include "invokeslot.h"

namespace PerlQt5 {

InvokeSlot::ReturnValue::ReturnValue(Smoke* smoke, const QMetaMethod& method, SV* returnValue, void** a) :
    m_smoke(smoke), m_returnValue(returnValue), m_metaMethod(method), m_a(a) {

    m_type = SmokePerl::SmokeType::find(m_metaMethod.typeName(), m_smoke);

    SmokePerl::setPtrFromStackItem(
        type(),
        m_stackItem,
        &m_a[0]
    );

    Marshall::HandlerFn fn = getMarshallFn(type());
    (*fn)(this);
}

InvokeSlot::InvokeSlot(const QMetaMethod& method, SV* self, void** a, SV* code) :
        m_a(a), m_metaMethod(method), m_current(-1), m_called(false),
        m_code(code) {

    m_smoke = qtcore_Smoke;

    m_hasSelf = (self != nullptr);
    // hasSelf determines if we make room in the argument stack for $self
    int argc = method.parameterCount() + (m_hasSelf ? 1 : 0);

    m_smokeTypes = new SmokePerl::SmokeType[argc];
    for (int i = 0; i < method.parameterCount(); ++i) {
        m_smokeTypes[i] = SmokePerl::SmokeType::find(method.parameterTypes().at(i).constData(), m_smoke);
    }

    dSP;
    ENTER;
    SAVETMPS;
    PUSHMARK(SP);
    // Reserve space on the stack for our arguments.
    EXTEND(SP, argc);
    m_argv = SP + 1;
    SP += argc;
    PUTBACK;

    for (int i = 0; i < argc; ++i)
        m_argv[i] = sv_newmortal();
    if (m_hasSelf) {
        // Put $self in @_
        sv_setsv(m_argv[0], self);
    }

    m_stack = new Smoke::StackItem[argc];
}

InvokeSlot::~InvokeSlot() {
    delete[] m_smokeTypes;
    delete[] m_stack;
}

SmokePerl::SmokeType InvokeSlot::type() const {
    return m_smokeTypes[m_current];
}

Smoke::StackItem& InvokeSlot::item() const {
    SmokePerl::setStackItem(
        type(),
        m_stack[m_current + (m_hasSelf ? 1 : 0)],
        m_a[m_current + 1]
    );
    return m_stack[m_current + (m_hasSelf ? 1 : 0)];
}

void InvokeSlot::unsupported() const {
    croak("Unsupported type %s", type().name());
}

void InvokeSlot::callMethod() {
    if (m_called)
        return;
    m_called = true;

    // Call the method in scalar context
    I32 callFlags = G_SCALAR;
    call_sv(m_code, callFlags);

    // Marshall the return value
    dSP;
    ReturnValue result(m_smoke, m_metaMethod, POPs, m_a);

    PUTBACK;
    FREETMPS;
    LEAVE;
}

void InvokeSlot::next() {
    int previous = m_current;
    ++m_current;

    while (!m_called && m_current < m_metaMethod.parameterCount()) {
        Marshall::HandlerFn fn = getMarshallFn(type());
        (*fn)(this);
        ++m_current;
    }
    callMethod();
    m_current = previous;
}

}
