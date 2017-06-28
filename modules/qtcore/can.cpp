#include <QMetaObject>
#include <QMetaMethod>

#include "can.h"
#include "smokeobject.h"
#include "perlqtmetaobject.h"
#include "xsfunctions.h"

XS(XS_QOBJECT_CAN) {
    // This function is a bit odd, because it calls XS_CAN without setting up
    // an explicit stack space for it.  dXSARGS expands to a call to POPMARK.
    // Because XS_CAN calls dXSARGS, we don't want to call it here.  But we
    // still want to be able to read from the current variables on the stack,
    // and the ST macro requires the mark and ax variables.  Set these up the
    // same way that dXSARGS would, without calling POPMARK.
    dSP;
    I32 oldmark = TOPMARK;
    SV **mark = PL_stack_base + TOPMARK;
    dAX;

    const char* methodName = SvPVX(ST(1));
    SV* self = ST(0);

    // Call XS_CAN to see if this is a normal method
    XS_CAN(aTHX_ cv);

    // Get the number of items returned from XS_CAN by comparing the position
    // of the stack pointer.
    int count = PL_stack_sp - (PL_stack_base + oldmark);

    // If XS_CAN didn't find a method named methodName, count will be 0.
    if (count == 0) {
        // Look in this object's QMetaObject to see if there is a method
        // matching methodName.  For signals that are private (the last
        // argument is a QPrivateSignal struct declared private by the Q_OBJECT
        // macro), they won't appear in the smoke method list.  In this case,
        // we look at the methods defined in the QMetaObject.
        const char* package;
        if (SvTYPE(self) == SVt_PV) {
            package = SvPVX(self);
        }
        else {
            // self must be a reference
            package = HvNAME(SvSTASH(SvRV(self)));
        }

        SV* metaObjectSV = PerlQt5::MetaObjectManager::instance().getMetaObjectForPackage(package);
        SmokePerl::Object* obj = SmokePerl::Object::fromSV(metaObjectSV);
        QMetaObject* metaObject = (QMetaObject*)obj->cast(obj->classId.smoke->findClass("QMetaObject"));

        // Execute a linear search
        for (int i = 0; i < metaObject->methodCount(); ++i) {
            if (methodName == metaObject->method(i).name()) {
                // Got a match.  Make a Method instance.
                ENTER;
                SAVETMPS;
                PUSHMARK(SP);
                XPUSHs(sv_2mortal(newSVpv("SmokePerl::Method", 0)));
                XPUSHs(self);
                XPUSHs(sv_2mortal(newSVpv(methodName, 0)));
                XPUSHs(&PL_sv_undef);
                PUTBACK;
                HV* bsStash = gv_stashpv("SmokePerl::Method", 0);
                GV* gv = gv_fetchmethod_autoload(bsStash, "new", 1);
                call_sv((SV*)GvCV(gv), G_SCALAR);
                SPAGAIN;
                SV* boundSignal = newSVsv(POPs);
                PUTBACK;
                FREETMPS;
                LEAVE;
                ST(0) = sv_2mortal(boundSignal);
                XSRETURN(1);
            }
        }
    }
    XSRETURN(count);
}
