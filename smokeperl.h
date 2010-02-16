#ifndef SMOKEPERL_H
#define SMOKEPERL_H

#include "smoke.h"
#include "marshall.h"
#include <QtCore/qbytearray.h>

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

class SmokeClass {
    Smoke::Class *_c;
    Smoke *_smoke;
    Smoke::Index _id;
public:
    SmokeClass(const SmokeType &t) {
	_smoke = t.smoke();
	_id = t.classId();
	_c = _smoke->classes + _id;
    }
    SmokeClass(Smoke *smoke, Smoke::Index id) : _smoke(smoke), _id(id) {
	_c = _smoke->classes + _id;
    }

    Smoke *smoke() const { return _smoke; }
    const Smoke::Class &c() const { return *_c; }
    Smoke::Index classId() const { return _id; }
    const char *className() const { return _c->className; }
    Smoke::ClassFn classFn() const { return _c->classFn; }
    Smoke::EnumFn enumFn() const { return _c->enumFn; }
    bool operator ==(const SmokeClass &b) const {
	const SmokeClass &a = *this;
	if(a.className() == b.className()) return true;
	if(a.className() && b.className() && qstrcmp(a.className(), b.className()) == 0)
	    return true;
	return false;
    }
    bool operator !=(const SmokeClass &b) const {
	const SmokeClass &a = *this;
	return !(a == b);
    }
    bool isa(const SmokeClass &sc) const {
	// This is a sick function, if I do say so myself
	if(*this == sc) return true;
	Smoke::Index *parents = _smoke->inheritanceList + _c->parents;
	for(int i = 0; parents[i]; i++) {
	    if(SmokeClass(_smoke, parents[i]).isa(sc)) return true;
	}
	return false;
    }

    unsigned short flags() const { return _c->flags; }
    bool hasConstructor() const { return flags() & Smoke::cf_constructor; }
    bool hasCopy() const { return flags() & Smoke::cf_deepcopy; }
    bool hasVirtual() const { return flags() & Smoke::cf_virtual; }
    bool hasFire() const { return !(flags() & Smoke::cf_undefined); }
};
/*
 * Type handling by moc is simple.
 *
 * If the type name matches /^(?:const\s+)?\Q$types\E&?$/, use the
 * static_QUType, where $types is join('|', qw(bool int double char* QString);
 *
 * Everything else is passed as a pointer! There are types which aren't
 * Smoke::tf_ptr but will have to be passed as a pointer. Make sure to keep
 * track of what's what.
 *
 * Simply using typeids isn't enough for signals/slots. It will be possible
 * to declare signals and slots which use arguments which can't all be
 * found in a single smoke object. Instead, we need to store smoke => typeid
 * pairs. We also need additional informatation, such as whether we're passing
 * a pointer to the union element.
 */

enum MocArgumentType {
    xmoc_ptr,
    xmoc_bool,
    xmoc_int,
    xmoc_uint,
    xmoc_long,
    xmoc_ulong,
    xmoc_double,
    xmoc_charstar,
    xmoc_QString,
    xmoc_void
};

struct MocArgument {
    // smoke object and associated typeid
    SmokeType st;
    MocArgumentType argType;
};

#endif //SMOKEPERL_H
