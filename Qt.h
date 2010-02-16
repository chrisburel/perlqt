#ifndef QTSIMPLE_H
#define QTSIMPLE_H

#ifdef do_open
#undef do_open
#endif

#ifdef do_close
#undef do_close
#endif
#include "QtCore/QHash"

namespace PerlQt {
class Binding : public SmokeBinding {
public:
    Binding() : SmokeBinding(0) {};

    Binding(Smoke *s) : SmokeBinding(s) {}

    void deleted(Smoke::Index classId, void *ptr) {
        // Ignore deletion
    }

    bool callMethod(Smoke::Index method, void *ptr, Smoke::Stack args, bool) {
        return false;
    }

    char *className(Smoke::Index classId) {
        const char *className = smoke->className(classId);
        char *buf = new char[strlen(className) + 12];
        strcpy(buf, " QtSimple::");
        strcat(buf, className);
        return buf;
    }
};
}

struct PerlQtModule {
    char* name;
    PerlQt::Binding *binding;
};

extern QHash<Smoke*, PerlQtModule> perlqt_modules;
#endif
