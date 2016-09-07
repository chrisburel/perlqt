#ifndef SMOKEPERL_SMOKEOBJECT
#define SMOKEPERL_SMOKEOBJECT

#include <unordered_map>

#include <smoke.h>

extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

namespace SmokePerl {

class ObjectMap {
public:
    static ObjectMap& instance() {
        static ObjectMap instance;
        return instance;
    }

    SV* get(const void* ptr) const;

    ObjectMap(ObjectMap const&) = delete;
    void operator=(ObjectMap const&) = delete;
private:
    ObjectMap() {};
    std::unordered_map<const void *, SV*> perlVariablesMap;

};

class Object {
public:
    enum ValueOwnership {
        QtOwnership,
        ScriptOwnership
    };

    Object(void* ptr, const Smoke::ModuleIndex& classId, ValueOwnership ownership);
    static Object* fromSV(SV* sv);

    static int free(pTHX_ SV* sv, MAGIC* mg);
    SV* wrap() const;

    inline void* cast(const Smoke::ModuleIndex targetId) const {
        return classId.smoke->cast(value, classId, targetId);
    }

    void* value;
    Smoke::ModuleIndex classId;
    ValueOwnership ownership;
    static constexpr MGVTBL vtbl_smoke { 0, 0, 0, 0, free };
};

}


#endif
