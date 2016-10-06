#include <QMetaMethod>

#include "smokeobject.h"
#include "invokeslot.h"

namespace PerlQt5 {

InvokeSlot::InvokeSlot(const QMetaMethod& method, SV* self, void** a, SV* code) :
    m_self(self), m_a(a), m_metaMethod(method),
    m_current(-1), m_called(false), m_code(code) {

    SmokePerl::Object* obj = SmokePerl::Object::fromSV(self);
    m_smoke = obj->classId.smoke;

    int argc = method.parameterTypes().count();

    m_smokeTypes = new SmokePerl::SmokeType[argc + 1];
    for (int i = 0; i < argc; ++i) {
        m_smokeTypes[i] = SmokePerl::SmokeType::find(method.parameterTypes().at(i).constData(), m_smoke);
    }

    dSP;
    ENTER;
    SAVETMPS;
    PUSHMARK(SP);
    // Reserve space on the stack for our arguments.  Remember to make space
    // for $self
    EXTEND(SP, argc + 1);

    m_argv = SP + 1;
    for (int i = 0; i < argc + 1; ++i)
        m_argv[i] = sv_newmortal();
    // Put $self in @_
    sv_setsv(m_argv[0], self);

    m_stack = new Smoke::StackItem[argc + 1];
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
        m_stack[m_current + 1],
        m_a[m_current + 1]
    );
    return m_stack[m_current + 1];
}

void InvokeSlot::unsupported() const {
    croak("Unsupported type %s", type().name());
}

void InvokeSlot::callMethod() {
    if (m_called)
        return;
    m_called = true;

    // Set up the stack pointer
    dSP;
    SP = m_argv + m_metaMethod.parameterTypes().count();
    PUTBACK;

    // Find the method to call
    GV* gv = gv_fetchmethod_autoload(SvSTASH(SvRV(m_self)), m_metaMethod.name(), 0);

    // Call the method in scalar context
    I32 callFlags = G_SCALAR;
    call_sv(m_code, callFlags);

    PUTBACK;
    FREETMPS;
    LEAVE;
}

void InvokeSlot::next() {
    int previous = m_current;
    ++m_current;

    while (!m_called && m_current < m_metaMethod.parameterTypes().count()) {
        Marshall::HandlerFn fn = getMarshallFn(type());
        (*fn)(this);
        ++m_current;
    }
    callMethod();
    m_current = previous;
}

}
