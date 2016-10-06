#ifndef SMOKEPERL_MARSHALL
#define SMOKEPERL_MARSHALL

#include <string>
#include <unordered_map>

#include <smoke.h>

#include "smokemanager.h"

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

namespace SmokePerl {

class SmokeType {
    Smoke::Type *m_type;        // derived from _smoke and _id, but cached
    Smoke *m_smoke;
    Smoke::Index m_id;
public:
    SmokeType() : m_type(0), m_smoke(0), m_id(0) {}
    SmokeType(Smoke *s, Smoke::Index i) : m_smoke(s), m_id(i) {
        if (m_id < 0 || m_id > m_smoke->numTypes) {
            m_id = 0;
        }
        m_type = m_smoke->types + m_id;
    }
    // default copy constructors are fine, this is a constant structure

    static SmokeType find(const char* typeName, Smoke* smoke) {
        Smoke::Index typeId = smoke->idType(typeName);
        if (typeId != 0) {
            SmokeType result(smoke, typeId);

            if ((result.element() == Smoke::t_voidp || result.element() == Smoke::t_class) && result.isStack()) {
                return find((std::string(typeName) + '*').c_str(), smoke);
            }
            return result;
        }

        for (const auto& s : SmokeManager::instance().getSmokes()) {
            typeId = s->idType(typeName);
            if (typeId != 0) {
                SmokeType result(s, typeId);

                if ((result.element() == Smoke::t_voidp || result.element() == Smoke::t_class) && result.isStack()) {
                    return find((std::string(typeName) + '*').c_str(), s);
                }
                return result;
            }
        }

        return SmokeType(smoke, 0);
    }

    // mutators
    void set(Smoke *s, Smoke::Index i) {
        m_smoke = s;
        m_id = i;
        m_type = m_smoke->types + m_id;
    }

    // accessors
    Smoke *smoke() const { return m_smoke; }
    Smoke::Index typeId() const { return m_id; }
    const Smoke::Type &type() const { return *m_type; }
    unsigned short flags() const { return m_type->flags; }
    unsigned short element() const { return m_type->flags & Smoke::tf_elem; }
    const char *name() const { return m_type->name; }
    Smoke::Index classId() const { return m_type->classId; }

    // tests
    bool isStack() const { return ((flags() & Smoke::tf_ref) == Smoke::tf_stack); }
    bool isPtr() const { return ((flags() & Smoke::tf_ref) == Smoke::tf_ptr); }
    bool isRef() const { return ((flags() & Smoke::tf_ref) == Smoke::tf_ref); }
    bool isConst() const { return (flags() & Smoke::tf_const); }
    bool isClass() const {
        return element() == Smoke::t_class && classId() != 0;
    }

    bool operator==(const SmokeType &b) const {
        const SmokeType &a = *this;
        if (a.name() == b.name()) {
            return true;
        }

        if (a.name() && b.name() && strcmp(a.name(), b.name()) == 0) {
            return true;
        }

        return false;
    }

    bool operator!=(const SmokeType &b) const {
        const SmokeType &a = *this;
        return !(a == b);
    }

};

class Marshall {
public:
    typedef void (*HandlerFn)(Marshall *);
    enum Action {
        FromSV,
        ToSV
    };
    virtual SmokeType type() const = 0;
    virtual Action action() const = 0;
    virtual Smoke::StackItem& item() const = 0;
    virtual SV* var() const = 0;
    virtual void unsupported() const = 0;
    virtual Smoke* smoke() const = 0;
    virtual void next() = 0;
    virtual bool cleanup() const = 0;
    virtual ~Marshall() {}

    static void installHandlers(const std::unordered_map<std::string, HandlerFn>& handlers);
    static Marshall::HandlerFn getMarshallFn(const SmokeType& type);

    typedef SV* (*MarshallFunction)(const void*);
    typedef void (*DemarshallFunction)(SV*, void*);
};

void setStackItem(const SmokeType& type, Smoke::StackItem& stackItem, void* ptr);
void setPtrFromStackItem(const SmokeType& type, Smoke::StackItem& stackItem, void** ptr);

}

#endif
