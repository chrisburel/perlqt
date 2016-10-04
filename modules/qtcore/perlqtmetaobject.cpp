#include <QObject>
#include <QMetaObject>

#define QMETAOBJECT_PRIVATE_HEADER QtCore/private/qmetaobjectbuilder_p.h
#include QT_STRINGIFY(PERLQT_QT_VERSION/QMETAOBJECT_PRIVATE_HEADER)

#include <qtcore_smoke.h>

#include "methodcall.h"
#include "smokemanager.h"
#include "smokeobject.h"
#include "perlqtmetaobject.h"

namespace PerlQt5 {

SV* MetaObjectManager::getMetaObjectForPackage(const char* package) {

    QMetaObject* metaObject;

    if (packageToMetaObject.count(package)) {
        metaObject = packageToMetaObject.at(package);
    }
    else {
        dXSARGS;

        HV* stash = gv_stashpv(package, 0);

        // See if package is a c++ class
        std::string cppClassName = SmokePerl::SmokeManager::instance().getClassForPackage(package);
        if (!cppClassName.empty()) {
            // Get metaObject for c++ class by calling staticMetaObject
            GV* gv = gv_fetchmethod_autoload(stash, "__PERLQT5__INTERNAL", 1);
            CV* cv = GvCV(gv);
            sv_setpvn((SV*)cv, "staticMetaObject", 16);
            SvPOK_off(cv);

            ENTER;
            SAVETMPS;
            PUSHMARK(SP);
            mXPUSHp(package, strlen(package));
            PUTBACK;
            items = call_sv((SV*)cv, G_SCALAR);
            SPAGAIN;
            SP -= items;
            ax = (SP - PL_stack_base) + 1;
            SmokePerl::Object* metaSmokeObject = SmokePerl::Object::fromSV(ST(0));
            metaObject = (QMetaObject*)metaSmokeObject->cast(metaSmokeObject->classId.smoke->findClass("QMetaObject"));
            PUTBACK;
            FREETMPS;
            LEAVE;
        }
        else {
            // Got a perl type.  Build its metaobject.
            QMetaObjectBuilder b;
            b.setClassName(package);

            // Get the parent class's metaobject
            AV* mro = mro_get_linear_isa(stash);
            SV* superPackage = *av_fetch(mro, 1, 0);
            GV* gv = gv_fetchmethod_autoload(gv_stashsv(superPackage, 0), "staticMetaObject", 0);

            ENTER;
            SAVETMPS;
            PUSHMARK(SP);
            XPUSHs(superPackage);
            PUTBACK;
            items = call_sv((SV*)GvCV(gv), G_SCALAR);
            SPAGAIN;
            SP -= items;
            ax = (SP - PL_stack_base) + 1;
            SmokePerl::Object* superMetaSmokeObject = SmokePerl::Object::fromSV(ST(0));
            QMetaObject* superMetaObject = (QMetaObject*)superMetaSmokeObject->cast(superMetaSmokeObject->classId.smoke->findClass("QMetaObject"));
            b.setSuperClass(superMetaObject);
            PUTBACK;
            FREETMPS;
            LEAVE;

            metaObject = b.toMetaObject();
        }

        packageToMetaObject[package] = metaObject;
    }
    SV* retval = newSV(0);
    Smoke::StackItem stackItem;
    stackItem.s_voidp = metaObject;
    Smoke::ModuleIndex methodId = qtcore_Smoke->findMethod("QObject", "staticMetaObject");
    methodId.index = qtcore_Smoke->methodMaps[methodId.index].method;
    SmokePerl::MethodCall::ReturnValue retvalMarshaller(methodId, &stackItem, retval);

    return retval;
}

}

XS(XS_QOBJECT_STATICMETAOBJECT) {
    dXSARGS;

    SV* package = ST(0);

    ST(0) = PerlQt5::MetaObjectManager::instance().getMetaObjectForPackage(SvPV_nolen(package));

    sv_2mortal(ST(0));
    XSRETURN(1);
}

XS(XS_QOBJECT_METAOBJECT) {
    dXSARGS;

    const char* package = HvNAME(SvSTASH(SvRV(ST(0))));

    ST(0) = PerlQt5::MetaObjectManager::instance().getMetaObjectForPackage(package);

    sv_2mortal(ST(0));
    XSRETURN(1);
}
