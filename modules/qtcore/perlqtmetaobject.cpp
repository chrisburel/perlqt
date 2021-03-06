#include <QObject>
#include <QMetaObject>

#include <QtCore/private/qmetaobjectbuilder_p.h>

#include <qtcore_smoke.h>

#include "methodcall.h"
#include "smokemanager.h"
#include "smokeobject.h"
#include "perlqtmetaobject.h"
#include "invokeslot.h"

namespace PerlQt5 {

MetaObjectManager::~MetaObjectManager() {
    for (const auto& pair : packageToMetaObject) {
        if (pair.second.ownedByPerl) {
            free(pair.second.metaObject);
        }
    }
}

SV* MetaObjectManager::getMetaObjectForPackage(const char* package) {

    QMetaObject* metaObject;

    if (packageToMetaObject.count(package)) {
        metaObject = packageToMetaObject.at(package).metaObject;
    }
    else {
        dSP;

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
            int items = call_sv((SV*)cv, G_SCALAR);
            SPAGAIN;
            SP -= items;
            I32 ax = (SP - PL_stack_base) + 1;
            SmokePerl::Object* metaSmokeObject = SmokePerl::Object::fromSV(ST(0));
            metaObject = (QMetaObject*)metaSmokeObject->cast(metaSmokeObject->classId.smoke->findClass("QMetaObject"));
            PUTBACK;
            FREETMPS;
            LEAVE;
            packageToMetaObject[package] = {false, metaObject};
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
            int items = call_sv((SV*)GvCV(gv), G_SCALAR);
            SPAGAIN;
            SP -= items;
            I32 ax = (SP - PL_stack_base) + 1;
            SmokePerl::Object* superMetaSmokeObject = SmokePerl::Object::fromSV(ST(0));
            QMetaObject* superMetaObject = (QMetaObject*)superMetaSmokeObject->cast(superMetaSmokeObject->classId.smoke->findClass("QMetaObject"));
            b.setSuperClass(superMetaObject);
            PUTBACK;
            FREETMPS;
            LEAVE;

            metaObject = b.toMetaObject();
            packageToMetaObject[package] = {true, metaObject};
        }

    }
    SV* retval = newSV(0);
    Smoke::StackItem stackItem;
    stackItem.s_voidp = metaObject;
    Smoke::ModuleIndex methodId = qtcore_Smoke->findMethod("QObject", "staticMetaObject");
    methodId.index = qtcore_Smoke->methodMaps[methodId.index].method;
    SmokePerl::MethodCall::ReturnValue retvalMarshaller(methodId, &stackItem, retval);

    return retval;
}

void MetaObjectManager::addSlot(QMetaObject*& metaObject, const std::string& slotName, const std::vector<std::string>& argTypes) {
    {
        // Put the QMetaObjectBuilder into its own block, so that it is cleaned
        // up before the end of the method.  The QMetaObjectBuilder references
        // the existing QMetaObject, which may be cleaned up.  The
        // QMetaObjectBuilder needs to be cleaned up before the metaObject it
        // references is cleaned up.
        QMetaObjectBuilder b(metaObject);
        std::string signature;
        signature += slotName;
        signature += '(';
        for (const auto& typeName : argTypes) {
            signature += typeName + ", ";
        }
        signature += ')';
        QMetaMethodBuilder method = b.addSlot(signature.c_str());
        metaObject = b.toMetaObject();
    }
    if (packageToMetaObject.count(metaObject->className())) {
        MetaObjectInfo info = packageToMetaObject[metaObject->className()];
        if (info.ownedByPerl) {
            if (SmokePerl::Object* obj = SmokePerl::ObjectMap::instance().get(info.metaObject)) {
                SmokePerl::ObjectMap::instance().remove(obj, obj->classId);
            }
            free(info.metaObject);
        }
    }
    packageToMetaObject[metaObject->className()] = {true, metaObject};
    installMetacall(metaObject);
}

void MetaObjectManager::installMetacall(QMetaObject* metaObject) const {
    GV* gv = gv_fetchmethod_autoload(gv_stashpv(metaObject->className(), 0), "qt_metacall", 0);
    if (gv != nullptr) {
        // If we found a gv, but it is not in the direct package specified (and
        // instead was looked up via @ISA), then the method doesn't exist in
        // the package yet.
        if (strcmp(metaObject->className(), HvNAME(GvSTASH(gv))) != 0) {
            gv = nullptr;
        }
    }
    if (!gv) {
        newXS(
            (std::string(metaObject->className()) + "::qt_metacall").c_str(),
            XS_QOBJECT_METACALL,
            __FILE__
        );
    }
}

QObjectSlotDispatcher::QObjectSlotDispatcher() :
    QtPrivate::QSlotObjectBase(&impl), signalIndex(-1)
{
}

QObjectSlotDispatcher::~QObjectSlotDispatcher() {
    if (func != nullptr) {
        SvREFCNT_dec(func);
    }
}

void QObjectSlotDispatcher::impl(int which, QSlotObjectBase *this_, QObject *r, void **metaArgs, bool *ret) {
    switch (which) {
        case Destroy: {
            delete static_cast<QObjectSlotDispatcher*>(this_);
        }
        break;
        case Call: {
            QObjectSlotDispatcher* This = static_cast<QObjectSlotDispatcher*>(this_);
            PerlQt5::InvokeSlot slot(This->method, nullptr, metaArgs, This->func);
            slot.next();
        }
        break;
        case Compare: {
            QObjectSlotDispatcher* This = static_cast<QObjectSlotDispatcher*>(this_);

            SV* func = reinterpret_cast<SV*>(metaArgs[0]);
            if (!SvOK(func) || !(SvROK(func))) {
                *ret = false;
                return;
            }

            *ret = (SvRV(func) == SvRV(This->func));
            return;
        }
        break;
        case NumOperations:
        break;
    }
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

XS(XS_QOBJECT_METACALL) {
    dXSARGS;
    SV* selfSV = ST(0);
    SV* cSV = ST(1);
    SV* idSV = ST(2);
    SV* argvSV = ST(3);

    // Call the super class's qt_metacall to see if they handle this call
    HV* stash = GvSTASH(CvGV(cv));
    AV* mro = mro_get_linear_isa(stash);
    SV* superPackage = *av_fetch(mro, 1, 0);
    GV* gv = gv_fetchmethod_autoload(gv_stashsv(superPackage, 0), "qt_metacall", 1);
    ENTER;
    SAVETMPS;
    PUSHMARK(SP);
    XPUSHs(selfSV);
    XPUSHs(cSV);
    XPUSHs(idSV);
    XPUSHs(argvSV);
    PUTBACK;
    items = call_sv((SV*)GvCV(gv), G_SCALAR);
    SPAGAIN;
    SP -= items;
    ax = (SP - PL_stack_base) + 1;
    int id = SvIV(ST(0));
    PUTBACK;
    FREETMPS;
    LEAVE;

    if (id < 0) {
        ST(0) = sv_2mortal(newSViv(id));
        XSRETURN(1);
    }

    SV* metaObjectSV = PerlQt5::MetaObjectManager::instance().getMetaObjectForPackage(HvNAME(stash));
    SmokePerl::Object* metaSmokeObject = SmokePerl::Object::fromSV(metaObjectSV);
    QMetaObject* metaObject = (QMetaObject*)metaSmokeObject->cast(metaSmokeObject->classId.smoke->findClass("QMetaObject"));

    QMetaObject::Call c = (QMetaObject::Call)SvIV(SvRV(cSV));
    void** argv = (void**)SmokePerl::Object::fromSV(argvSV)->value;
    id = SvIV(idSV);

    switch (c) {
        case QMetaObject::InvokeMetaMethod:
        {
            if (id < metaObject->methodCount()) {
                QMetaMethod method = metaObject->method(id);

                GV* gv = gv_fetchmethod_autoload(SvSTASH(SvRV(selfSV)), method.name(), 0);
                PerlQt5::InvokeSlot slot(method, selfSV, argv, (SV*)GvCV(gv));
                slot.next();
            }
            id -= metaObject->methodCount();
        }
    }

    // Return our new id.
    ST(0) = sv_2mortal(newSViv(id));
    XSRETURN(1);
}

XS(XS_QTCORE_SIGNAL_CONNECT) {
    dXSARGS;

    HV* signal = (HV*)SvRV(ST(0));
    SV* func = ST(1);

    SV* self = *hv_fetch(signal, "instance", 8, 0);
    int signalIndex = SvIV(*hv_fetch(signal, "signalIndex", 11, 0));

    SmokePerl::Object* objSmokeObj = SmokePerl::Object::fromSV(self);
    QObject* obj = (QObject*)objSmokeObj->cast(objSmokeObj->classId.smoke->findClass("QObject"));

    PerlQt5::QObjectSlotDispatcher *slot = new PerlQt5::QObjectSlotDispatcher;
    slot->signalIndex = signalIndex;
    slot->method = obj->metaObject()->method(signalIndex);
    slot->func = newSVsv(func);
    QMetaObject::Connection conn = QObjectPrivate::connect(obj, signalIndex, slot, Qt::AutoConnection);

    XSRETURN_UNDEF;
}

XS(XS_QTCORE_SIGNAL_DISCONNECT) {
    dXSARGS;

    HV* signal = (HV*)SvRV(ST(0));
    SV* func = ST(1);

    SV* self = *hv_fetch(signal, "instance", 8, 0);
    int signalIndex = SvIV(*hv_fetch(signal, "signalIndex", 11, 0));

    SmokePerl::Object* objSmokeObj = SmokePerl::Object::fromSV(self);
    QObject* obj = (QObject*)objSmokeObj->cast(objSmokeObj->classId.smoke->findClass("QObject"));

    void* a[] = {
        func
    };

    bool success = QObjectPrivate::disconnect(obj, signalIndex, reinterpret_cast<void**>(&a));

    success ? XST_mYES(0) : XST_mNO(0);
    XSRETURN(1);
}
