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

class Object;

class ObjectMap {
public:
    static ObjectMap& instance() {
        static ObjectMap instance;
        return instance;
    }

    Object* get(const void* ptr) const;
    void insert(Object* obj, const Smoke::ModuleIndex& classId, void* lastptr=nullptr);
    void remove(Object* obj, const Smoke::ModuleIndex& classId, void* lastptr=nullptr);

    ObjectMap(ObjectMap const&) = delete;
    void operator=(ObjectMap const&) = delete;
private:
    ObjectMap() {};
    std::unordered_map<const void *, Object*> perlVariablesMap;

};

class Object {
public:
    enum ValueOwnership {
        CppOwnership,
        ScriptOwnership
    };

    Object(void* ptr, const Smoke::ModuleIndex& classId, ValueOwnership ownership);
    virtual ~Object();
    static Object* fromSV(SV* sv);

    static int free(pTHX_ SV* sv, MAGIC* mg);
    SV* wrap();

    inline void* cast(const Smoke::ModuleIndex targetId) const {
        return classId.smoke->cast(value, classId, targetId);
    }

    void* value;
    SV* sv;
    Smoke::ModuleIndex classId;
    ValueOwnership ownership;
    static constexpr MGVTBL vtbl_smoke { 0, 0, 0, 0, free };

private:
    void finalize();
    void dispose();
};

}


#endif
