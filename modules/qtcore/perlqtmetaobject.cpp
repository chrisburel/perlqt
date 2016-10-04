#include <QObject>
#include <QMetaObject>

#define QMETAOBJECT_PRIVATE_HEADER QtCore/private/qmetaobjectbuilder_p.h
#include QT_STRINGIFY(PERLQT_QT_VERSION/QMETAOBJECT_PRIVATE_HEADER)

#include "smokemanager.h"
#include "smokeobject.h"
#include "perlqtmetaobject.h"

XS(XS_QOBJECT_METAOBJECT) {
    dXSARGS;

    QMetaObject* metaObject;

    // Find the type of object we have
    SV* self;
    HV* stash;
    switch (items) {
        case 1:
            self = ST(0);
            stash = SvSTASH(SvRV(self));
            break;
        case 2:
            self = ST(1);
            stash = gv_stashsv(ST(0), 0);
            break;
    }
    const char* package = HvNAME(stash);

    // See if that is a c++ class
    std::string cppClassName = SmokePerl::SmokeManager::instance().getClassForPackage(package);
    if (!cppClassName.empty()) {
        // Got a c++ type, get its metaObject by a direct virtual method call
        SmokePerl::Object* obj = SmokePerl::Object::fromSV(self);
        QObject* object = (QObject*)obj->cast(obj->classId.smoke->findClass("QObject"));
        SmokePerl::SmokeManager::instance().setInVirtualSuperCall(
            std::string(obj->classId.smoke->classes[obj->classId.index].className) + "::metaObject"
        );
        metaObject = const_cast<QMetaObject*>(object->metaObject());
        SmokePerl::SmokeManager::instance().setInVirtualSuperCall("");
    }
    else {
        // Got a perl type.  Build its metaobject.
        QMetaObjectBuilder b;
        b.setClassName(HvNAME(stash));

        // Get the parent class's metaobject
        AV* mro = mro_get_linear_isa(stash);
        SV* superPackage = *av_fetch(mro, 1, 0);
        GV* superMetaObjectMethod = gv_fetchmethod(gv_stashsv(superPackage, 0), "metaObject");

        ENTER;
        SAVETMPS;
        PUSHMARK(SP);
        XPUSHs(superPackage);
        XPUSHs(self);
        PUTBACK;
        items = call_sv((SV*)GvCV(superMetaObjectMethod), G_SCALAR);
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

    SmokePerl::Object* obj = SmokePerl::ObjectMap::instance().get(metaObject);

    if (obj != nullptr) {
        ST(0) = newSVsv(obj->sv);
    }
    else {
        obj = new SmokePerl::Object(
            metaObject,
            Smoke::findClass("QMetaObject"),
            SmokePerl::Object::CppOwnership
        );

        SV* sv = obj->wrap();
        SmokePerl::ObjectMap::instance().insert(obj, obj->classId);

        sv_bless(sv, gv_stashpv("PerlQt5::QtCore::QMetaObject", TRUE));

        ST(0) = newSVsv(sv);
    }
    sv_2mortal(ST(0));
    XSRETURN(1);
}
