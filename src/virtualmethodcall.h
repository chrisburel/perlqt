#ifndef SMOKEPERL_VIRTUALMETHODCALL
#define SMOKEPERL_VIRTUALMETHODCALL

#include <smoke.h>
#include "marshall.h"

namespace SmokePerl {

class VirtualMethodCall : public Marshall {
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
            return Marshall::FromSV;
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

public:
    VirtualMethodCall(Smoke::ModuleIndex methodId, Smoke::Stack stack, SV* self, GV* gv);
    ~VirtualMethodCall();

    inline SmokeType type() const {
        return SmokeType(m_methodId.smoke, m_args[m_current]);
    }

    inline Marshall::Action action() const {
        return Marshall::ToSV;
    }

    inline Smoke::StackItem& item() const {
        return m_stack[m_current + 1];
    }

    inline SV* var() const {
        // The 0th spot is reserved for $self
        return m_argv[m_current + 1];
    }

    inline const Smoke::Method& method() const {
        return m_methodRef;
    }

    inline Smoke* smoke() const {
        return m_methodId.smoke;
    }

    inline bool cleanup() const {
        return false;
    }

    void unsupported() const;

    void callMethod();
    void next();

private:
    Smoke::ModuleIndex m_methodId;
    Smoke::Stack m_stack;
    Smoke::Index* m_args;
    SV* m_self;
    SV** m_argv;
    GV* m_gv;
    int m_current;
    bool m_called;
    Smoke::Method& m_methodRef;
};

}

#endif
