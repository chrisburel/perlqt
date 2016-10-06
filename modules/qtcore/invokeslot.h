#ifndef PERLQT5_INVOKESLOT
#define PERLQT5_INVOKESLOT

#include <smoke.h>
#include "marshall.h"

class QMetaMethod;

namespace PerlQt5 {

class InvokeSlot : public SmokePerl::Marshall {
    class ReturnValue : SmokePerl::Marshall {
    public:
        ReturnValue(Smoke* smoke, const QMetaMethod& method, SV* returnValue, void** a);

        inline SmokePerl::SmokeType type() const {
            return m_type;
        }

        inline Marshall::Action action() const {
            return Marshall::FromSV;
        }

        inline Smoke::StackItem& item() const {
            return const_cast<Smoke::StackItem&>(m_stackItem);
        }

        inline SV* var() const {
            return m_returnValue;
        }

        inline Smoke* smoke() const {
            return m_smoke;
        }

        inline bool cleanup() const {
            return false;
        }

        void unsupported() const {}
        void next() {}

    private:
        SV* m_returnValue;
        const QMetaMethod& m_metaMethod;
        void** m_a;
        Smoke* m_smoke;
        Smoke::StackItem m_stackItem;
        SmokePerl::SmokeType m_type;
    };

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
