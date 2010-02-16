#ifndef SMOKEPERL_H
#define SMOKEPERL_H

#include "smoke.h"
#include "marshall.h"

// keep this enum in sync with lib/Qt/debug.pm
enum SmokeDebugChannel {
    smokedb_none = 0x00,
    smokedb_ambiguous = 0x01,
    smokedb_autoload = 0x02,
    smokedb_calls = 0x04,
    smokedb_gc = 0x08,
    smokedb_virtual = 0x10,
    smokedb_verbose = 0x20
};

//extern struct mgvtbl vtbl_smoke;

struct smokeperl_object {
    bool allocated;
    Smoke *smoke;
    int classId;
    void *ptr;
};

inline smokeperl_object *sv_obj_info(SV *sv) {  // ptr on success, null on fail
    if(!sv || !SvROK(sv) || SvTYPE(SvRV(sv)) != SVt_PVHV)
        return 0;
    SV *obj = SvRV(sv);
    MAGIC *mg = mg_find(obj, '~');
    if(!mg ){//|| mg->mg_virtual != &vtbl_smoke) {
        // FIXME: die or something?
        return 0;
    }
    smokeperl_object *o = (smokeperl_object*)mg->mg_ptr;
    return o;
}

class SmokeType {
    // derived from _smoke and _id, but cached.  Index into types[] in smokedata.cpp

    Smoke::Type *_t;
    Smoke *_smoke;
    Smoke::Index _id;
public:
    SmokeType() : _t(0), _smoke(0), _id(0) {}
    SmokeType(Smoke *s, Smoke::Index i) : _smoke(s), _id(i) {
        if(_id < 0 || _id > _smoke->numTypes) _id = 0;
        _t = _smoke->types + _id;
    }
    // default copy constructors are fine, this is a constant structure

    // mutators
    void set(Smoke *s, Smoke::Index i) {
        _smoke = s;
        _id = i;
        _t = _smoke->types + _id;
    }
  
    // accessors
    Smoke *smoke() const { return _smoke; }
    Smoke::Index typeId() const { return _id; }
    const Smoke::Type &type() const { return *_t; }
    unsigned short flags() const { return _t->flags; }
    unsigned short elem() const { return _t->flags & Smoke::tf_elem; }
    const char *name() const { return _t->name; }
    Smoke::Index classId() const { return _t->classId; }

    // tests
    bool isStack() const { return ((flags() & Smoke::tf_ref) == Smoke::tf_stack); }
    bool isPtr() const { return ((flags() & Smoke::tf_ref) == Smoke::tf_ptr); }
    bool isRef() const { return ((flags() & Smoke::tf_ref) == Smoke::tf_ref); }
    bool isConst() const { return (flags() & Smoke::tf_const); }
    bool isClass() const {
        if(elem() == Smoke::t_class)
            return classId() ? true : false;
        return false;
    }

    bool operator ==(const SmokeType &b) const {
        const SmokeType &a = *this;
        if(a.name() == b.name()) return true;
        if(a.name() && b.name() && !strcmp(a.name(), b.name()))
            return true;
        return false;
    }
    bool operator !=(const SmokeType &b) const {
        const SmokeType &a = *this;
        return !(a == b);
    }
};

#endif //SMOKEPERL_H
