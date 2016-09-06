#include <smoke.h>

#include "methodcall.h"
#include "smokemanager.h"
#include "smokeobject.h"

namespace SmokePerl {

MethodCall::ReturnValue::ReturnValue(Smoke::ModuleIndex methodId, Smoke::Stack stack, SV* returnValue) :
    m_methodId(methodId), m_stack(stack), m_returnValue(returnValue) {
    Marshall::HandlerFn fn = getMarshallFn(type());
    (*fn)(this);
}

void MethodCall::ReturnValue::unsupported() const {
    croak("Unsupported type %s", type().name());
}

MethodCall::MethodCall(Smoke::ModuleIndex methodId, SV* self, SV** argv) :
    m_methodRef(methodId.smoke->methods[methodId.index]),
    m_current(-1), m_smoke(methodId.smoke), m_methodId(methodId),
    m_args(m_smoke->argumentList + m_methodRef.args),
    m_self(self), m_argv(argv), m_called(false) {

    m_returnValue = newSV(0);
    m_stack = new Smoke::StackItem[m_methodRef.numArgs + 1];
}

MethodCall::~MethodCall() {
    delete[] m_stack;
}

void MethodCall::callMethod() {
    if (m_called) {
        return;
    }

    m_called = true;

    if (m_self == &PL_sv_undef && !(m_methodRef.flags & Smoke::mf_static)) {
        croak("%s is not a class method\n", m_smoke->methodNames[m_methodRef.name]);
    }

    Smoke::ClassFn fn = m_smoke->classes[m_methodRef.classId].classFn;

    void* ptr = 0;
    SmokePerl::Object* obj = SmokePerl::Object::fromSV(m_self);
    if (obj != nullptr) {
        ptr = obj->value;
    }

    (*fn)(m_methodRef.method, ptr, m_stack);

    if ((m_methodRef.flags & Smoke::mf_ctor) != 0) {
        Smoke::StackItem initializeInstanceStack[2];
        initializeInstanceStack[1].s_voidp = SmokePerl::SmokeManager::instance().getBindingForSmoke(m_smoke);
        fn(0, m_stack[0].s_class, initializeInstanceStack);
    }

    ReturnValue result(m_methodId, m_stack, m_returnValue);
}

void MethodCall::next() {
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

void MethodCall::unsupported() const {
    croak("Unsupported type %s", type().name());
}

}
