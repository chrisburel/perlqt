#include <iostream>

#include <QObject>

#include <qtcore_smoke.h>

#include "methodcall.h"
#include "smokeobject.h"
#include "perlqtobject.h"

XS(XS_QOBJECT_DESTROY) {
    dXSARGS;
    if (PL_phase == PERL_PHASE_DESTRUCT) {
        return;
    }

    SmokePerl::Object* obj = SmokePerl::Object::fromSV(ST(0));
    QObject* qobj = (QObject*)obj->cast(obj->classId.smoke->findClass("QObject"));
    if (!qobj)
        return;

    QObject* qparent = qobj->parent();

    if (!qparent)
        return;

    SV* svParent = sv_newmortal();
    Smoke::StackItem stackItem;
    stackItem.s_voidp = qparent;
    Smoke::ModuleIndex methodId = qtcore_Smoke->findMethod("QObject", "parent");
    methodId.index = qtcore_Smoke->methodMaps[methodId.index].method;
    SmokePerl::MethodCall::ReturnValue retvalMarshaller(methodId, &stackItem, svParent);
    retvalMarshaller.next();

    SmokePerl::Object* smokeParent = SmokePerl::Object::fromSV(svParent);
    obj->setParent(smokeParent);
}
