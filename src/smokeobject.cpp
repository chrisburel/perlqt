#include "smokeobject.h"

namespace SmokePerl {

constexpr MGVTBL Object::vtbl_smoke;

SV* ObjectMap::get(const void* ptr) const {
    if (perlVariablesMap.count(ptr))
        return perlVariablesMap.at(ptr);
    return nullptr;
}

Object::Object(void* ptr, const Smoke::ModuleIndex& classId, ValueOwnership ownership) :
    value(ptr), classId(classId), ownership(ownership) {
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

SV* Object::wrap() const {
    SV* obj = (SV*) newHV();
    SV* ref = newRV_noinc((SV*)obj);

    sv_magicext((SV*)obj, 0, PERL_MAGIC_ext, &vtbl_smoke, (char*)this, sizeof(*this));

    return ref;
}

int Object::free(pTHX_ SV* sv, MAGIC* mg) {
    return 0;
}

}
