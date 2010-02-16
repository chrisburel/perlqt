#ifndef BINDING_H
#define BINDING_H

#include "smoke.h"

#ifndef Q_DECL_EXPORT
#define Q_DECL_EXPORT
#endif

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

#endif // BINDING_H
