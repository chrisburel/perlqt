#ifndef SMOKEPERL_METHODCALL
#define SMOKEPERL_METHODCALL

#include <smoke.h>
#include "marshall.h"

namespace SmokePerl {

class MethodCall : public Marshall {

public:
    class ReturnValue : Marshall {
    public:
        ReturnValue(Smoke::ModuleIndex methodId, Smoke::Stack stack, SV* returnValue);
        inline const Smoke::Method& method() const {
            return m_methodId.smoke->methods[m_methodId.index];
        }

        inline SmokeType type() const {
            return SmokeType(m_methodId.smoke, method().ret);
        }

        inline Marshall::Action action() const {
            return Marshall::ToSV;
        }

        inline Smoke::StackItem& item() const {
            return m_stack[0];
        }

        inline SV* var() const {
            return m_returnValue;
        }

        inline Smoke* smoke() const {
            return m_methodId.smoke;
        }

        inline bool cleanup() const {
            return false;
        }

        void unsupported() const;
        void next() {}

    private:
        Smoke::ModuleIndex m_methodId;
        Smoke::Stack m_stack;
        SV* m_returnValue;
    };

    MethodCall(Smoke::ModuleIndex mi, SV* self, SV** argv);
    ~MethodCall();

    inline SmokeType type() const {
        return SmokeType(m_smoke, m_args[m_current]);
    }

    inline Marshall::Action action() const {
        return Marshall::FromSV;
    }

    inline Smoke::StackItem& item() const {
        return m_stack[m_current + 1];
    }

    inline SV* var() const {
        if (m_current < 0) {
            return m_returnValue;
        }

        return m_argv[m_current];
    }

    inline Smoke* smoke() const {
        return m_smoke;
    }

    inline bool cleanup() const {
        return true;
    }

    void unsupported() const;

    void callMethod();
    void next();

private:
    Smoke::Method& m_methodRef;
    int m_current;
    Smoke* m_smoke;
    Smoke::Stack m_stack;
    Smoke::ModuleIndex m_methodId;
    Smoke::Index* m_args;
    SV* m_self;
    SV* m_returnValue;
    SV** m_argv;
    bool m_called;
};

}

#endif
