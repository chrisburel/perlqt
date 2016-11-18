#ifndef SMOKEPERL_SMOKEOBJECT
#define SMOKEPERL_SMOKEOBJECT

#include <memory>
#include <unordered_map>
#include <unordered_set>

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
    static ObjectMap& instance();

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

    bool isValid() {
        return validCppObject;
    }

    void setParent(Object* parent);
    void removeParent(bool giveOwnershipBack=true);
    void invalidate();

    void* value;
    SV* sv;
    Smoke::ModuleIndex classId;
    ValueOwnership ownership;
    static constexpr MGVTBL vtbl_smoke { 0, 0, 0, 0, free };

private:
    using ChildrenList = std::unordered_set<Object*>;

    struct ParentInfo {
        ParentInfo() : parent(nullptr) {}
        Object* parent;
        ChildrenList children;
    };

    std::unique_ptr<ParentInfo> parentInfo;
    bool validCppObject = true;

    void finalize();
    void dispose();
    void destroyParentInfo();
    void recursive_invalidate(std::unordered_set<Object*>& seen);
};

}


#endif
