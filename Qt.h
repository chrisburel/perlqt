#ifndef QT_H
#define QT_H

#include "smokeperl.h"

#ifdef do_open
#undef do_open
#endif

#ifdef do_close
#undef do_close
#endif
#include "QtCore/QHash"

namespace PerlQt {
class Q_DECL_EXPORT Binding : public SmokeBinding {
public:
    Binding();
    Binding(Smoke *s);
    void deleted(Smoke::Index classId, void *ptr);
    bool callMethod(Smoke::Index method, void *ptr, Smoke::Stack args, bool isAbstract);
    char *className(Smoke::Index classId);
};
}

extern Q_DECL_EXPORT SV *getPointerObject(void *ptr);
extern Q_DECL_EXPORT void mapPointer(SV *obj, smokeperl_object *o, HV *hv, Smoke::Index classId, void *lastptr);
extern Q_DECL_EXPORT void unmapPointer(smokeperl_object *o, Smoke::Index classId, void *lastptr);

// These guys support the new qt_Smoke->binding implementation
struct PerlQtModule {
    char* name;
    PerlQt::Binding *binding;
};

extern QHash<Smoke*, PerlQtModule> perlqt_modules;
#endif
