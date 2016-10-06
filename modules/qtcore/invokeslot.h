#ifndef PERLQT5_INVOKESLOT
#define PERLQT5_INVOKESLOT

#include <smoke.h>
#include "marshall.h"

class QMetaMethod;

namespace PerlQt5 {

class InvokeSlot : public SmokePerl::Marshall {
public:
    InvokeSlot(const QMetaMethod& method, SV* self, void** a, SV* code);
    ~InvokeSlot();

    SmokePerl::SmokeType type() const;
    inline Marshall::Action action() const {
        return Marshall::ToSV;
    }

    Smoke::StackItem& item() const;

    inline SV* var() const {
        // The 0th spot is reserved for $self
        return m_argv[m_current + 1];
    }

    inline Smoke* smoke() const {
        return m_smoke;
    }

    inline bool cleanup() const {
        return false;
    }

    void unsupported() const;
    void callMethod();
    void next();

private:
    SV* m_self;
    const QMetaMethod& m_metaMethod;
    SV** m_argv;
    void** m_a;
    Smoke* m_smoke;
    Smoke::Stack m_stack;
    SmokePerl::SmokeType* m_smokeTypes;
    int m_current;
    bool m_called;
    SV* m_code;
};

}

#endif
