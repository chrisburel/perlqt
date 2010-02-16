#ifndef QT_H
#define QT_H

#include "binding.h"
#include "smokeperl.h"

#ifdef do_open
#undef do_open
#endif

#ifdef do_close
#undef do_close
#endif
#include "QtCore/QHash"

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
