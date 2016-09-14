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

Object::Object(void* ptr, const Smoke::ModuleIndex& classId, ValueOwnership ownership) :
    value(ptr), sv(nullptr), classId(classId), ownership(ownership) {
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

    sv_magicext((SV*)hv, 0, PERL_MAGIC_ext, &vtbl_smoke, (char*)this, sizeof(*this));

    return sv;
}

int Object::free(pTHX_ SV* sv, MAGIC* mg) {
    return 0;
}

}
