#include <algorithm>
#include <iostream>
#include "smokeobject.h"

namespace SmokePerl {

constexpr MGVTBL Object::vtbl_smoke;

Object* ObjectMap::get(const void* ptr) const {
    if (perlVariablesMap.count(ptr))
        return perlVariablesMap.at(ptr);
    return nullptr;
}

void ObjectMap::insert(Object* obj, const Smoke::ModuleIndex& classId, void* lastptr) {
    Smoke* smoke = classId.smoke;
    void* ptr = obj->cast(classId);

    if (ptr != lastptr) {
        lastptr = ptr;

        perlVariablesMap[ptr] = obj;
    }

    for (Smoke::Index* parent = smoke->inheritanceList + smoke->classes[classId.index].parents;
         *parent != 0;
         parent++ ) {
        if (smoke->classes[*parent].external) {
            Smoke::ModuleIndex mi = Smoke::findClass(smoke->classes[*parent].className);
            if (mi != Smoke::NullModuleIndex) {
                insert(obj, mi, lastptr);
            }
        } else {
            insert(obj, Smoke::ModuleIndex(smoke, *parent), lastptr);
        }
    }

    return;
}

void ObjectMap::remove(Object* obj, const Smoke::ModuleIndex& classId, void* lastptr) {
    Smoke* smoke = classId.smoke;
    void* ptr = obj->cast(classId);

    if (ptr != lastptr) {
        lastptr = ptr;

        if (perlVariablesMap.count(ptr)) {
            perlVariablesMap.erase(ptr);
        }
    }
    for (Smoke::Index* parent = smoke->inheritanceList + smoke->classes[classId.index].parents;
         *parent != 0;
         parent++ ) {
        if (smoke->classes[*parent].external) {
            Smoke::ModuleIndex mi = Smoke::findClass(smoke->classes[*parent].className);
            if (mi != Smoke::NullModuleIndex) {
                remove(obj, mi, lastptr);
            }
        } else {
            remove(obj, Smoke::ModuleIndex(smoke, *parent), lastptr);
        }
    }
}

Object::Object(void* ptr, const Smoke::ModuleIndex& classId, ValueOwnership ownership) :
    value(ptr), sv(nullptr), classId(classId), ownership(ownership), parentInfo(new ParentInfo) {
}

Object::~Object() {
    destroyParentInfo();
    finalize();
}

Object* Object::fromSV(SV* sv) {
    if (!sv || !SvROK(sv) || !(SvTYPE(SvRV(sv)) == SVt_PVHV || SvTYPE(SvRV(sv)) == SVt_PVAV))
        return nullptr;
    MAGIC* mg = mg_findext(SvRV(sv), PERL_MAGIC_ext, &vtbl_smoke);
    if (!mg)
        return nullptr;
    Object* obj = (Object*)mg->mg_ptr;
    return obj;
}

SV* Object::wrap() {
    HV* hv = newHV();
    SvREFCNT(hv) = 0;
    sv = newRV_noinc((SV*)hv);

    sv_magicext((SV*)hv, 0, PERL_MAGIC_ext, &vtbl_smoke, (char*)this, 0);

    return sv;
}

int Object::free(pTHX_ SV* sv, MAGIC* mg) {
    Object* obj = (Object*)mg->mg_ptr;
    if (obj == nullptr)
        return 0;

    if (obj->classId != Smoke::NullModuleIndex)
        ObjectMap::instance().remove(obj, obj->classId);

    delete obj;
    mg->mg_ptr = 0;

    return 0;
}

void Object::setParent(Object* parent) {
    if (this == parent)
        return;

    bool parentIsNull = !parent;
    if (!parentIsNull) {
        // do not re-add a child
        if (parentInfo && (parentInfo->parent == parent))
            return;
    }

    bool hasAnotherParent = parentInfo && parentInfo->parent && parentInfo->parent != parent;

    // Avoid destroy child during reparent operation
    SvREFCNT_inc(SvRV(sv));

    if (parentIsNull || hasAnotherParent)
        removeParent();

    if (!parentIsNull) {
        parentInfo->parent = parent;
        parent->parentInfo->children.insert(this);

        // The parent now has a reference to us
        SvREFCNT_inc(SvRV(sv));

        // The parent is now responsible for managing this memory.  Remove our
        // ownership.
        ownership = CppOwnership;
    }

    // Remove previous safe ref
    SvREFCNT_dec(SvRV(sv));
}

void Object::removeParent(bool giveOwnershipBack) {
    if (parentInfo->parent == nullptr)
        return;

    ChildrenList& siblings = parentInfo->parent->parentInfo->children;
    // Verify if this child is pare of parent list
    ChildrenList::iterator iChild = std::find(siblings.begin(), siblings.end(), this);
    if (iChild == siblings.end())
        return;

    siblings.erase(iChild);

    parentInfo->parent = nullptr;

    ownership = giveOwnershipBack ? CppOwnership : ScriptOwnership;

    // Remove parent ref
    SvREFCNT_dec(SvRV(sv));
}

void Object::finalize() {
    switch (ownership) {
        case CppOwnership:
            break;
        case ScriptOwnership:
            dispose();
            break;
    };
}

void Object::dispose() {
    if (value == nullptr)
        return;

    std::string className(classId.smoke->classes[classId.index].className);
    std::size_t indexOfColon = className.rfind("::");
    std::string methodName;
    if (indexOfColon != std::string::npos) {
        methodName = '~' + className.substr(indexOfColon + 2);
    }
    else {
        methodName = '~' + className;
    }
    Smoke::ModuleIndex nameId = classId.smoke->findMethodName(
        classId.smoke->classes[classId.index].className,
        methodName.c_str()
    );

    Smoke::ModuleIndex methodId = classId.smoke->findMethod(classId, nameId);

    if (methodId.index > 0) {
        Smoke::Method& methodRef = methodId.smoke->methods[methodId.smoke->methodMaps[methodId.index].method];
        Smoke::ClassFn fn = methodId.smoke->classes[methodRef.classId].classFn;
        Smoke::StackItem destroyInstanceStack[1];
        (*fn)(methodRef.method, value, destroyInstanceStack);
    }

    value = nullptr;
    sv = nullptr;
}

void Object::destroyParentInfo() {
    while (!parentInfo->children.empty()) {
        // Mark child as invalid
        Object* child = *parentInfo->children.begin();
        child->invalidate();
        child->removeParent(false);
    }
    this->removeParent(false);
}

void Object::invalidate() {
    std::unordered_set<Object*> seen;
    recursive_invalidate(seen);
}

void Object::recursive_invalidate(std::unordered_set<Object*>& seen) {
    // Skip if this object not is a valid object or if it's already been seen
    if (seen.count(this) != 0)
        return;
    seen.insert(this);

    value = nullptr;

    // Create a copy because this list can be changed during the process
    ChildrenList copy = parentInfo->children;
    ChildrenList::iterator it = copy.begin();

    for (; it != copy.end(); ++it) {
        // invalidate the child
        (*it)->recursive_invalidate(seen);

        // if the parent not is a wrapper class, then remove children from
        // him, because We do not know when this object will be destroyed
        if (!isValid())
            (*it)->removeParent(true);
    }
}


}
