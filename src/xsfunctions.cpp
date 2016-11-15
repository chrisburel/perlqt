#include <iostream>

#define NO_XSLOCKS
#include "xsfunctions.h"
#include "methodresolution.h"
#include "smokemanager.h"
#include "smokeobject.h"
#include "methodcall.h"

XS(XS_AUTOLOAD) {
    dXSARGS;
    dXCPT;
    HV* stash = CvSTASH(cv);
    const char* package = HvNAME(stash);
    const char* methodName = SvPVX(cv);
    SV* self = ST(0);
    Smoke::ModuleIndex classId;
    if (SvTYPE(self) == SVt_PV) {
        std::string className = SmokePerl::SmokeManager::instance().getClassForPackage(package);
        if (className == "") {
            AV* mro = mro_get_linear_isa(stash);
            for (int i=0; i < av_len(mro), className == ""; ++i) {
                SV** item = av_fetch(mro, i, 0);
                if (item) {
                    className = SmokePerl::SmokeManager::instance().getClassForPackage(SvPV_nolen(*item));
                }
            }
        }
        classId = Smoke::findClass(className.c_str());
    }
    else {
        SmokePerl::Object* obj = SmokePerl::Object::fromSV(self);
        if (obj == nullptr)
            XSRETURN(0);
        classId = obj->classId;
    }

    GV* gv = gv_fetchmethod_autoload(stash, methodName, 0);
    if (gv) {
        SmokePerl::SmokeManager::instance().setInVirtualSuperCall(std::string(classId.smoke->classes[classId.index].className) + "::" + methodName);
    }

    bool isConstructor = strcmp(methodName, "new") == 0;
    if (isConstructor) {
        methodName = classId.smoke->classes[classId.index].className;
    }

    SmokePerl::MethodMatches matches = SmokePerl::resolveMethod(classId, methodName, items - 1, SP - items + 2);

    if (matches.size() == 0) {
        if (gv) {
            SmokePerl::SmokeManager::instance().setInVirtualSuperCall("");
        }
        matches.~vector<SmokePerl::MethodMatch>();
        croak("Unable to resolve method.");
    }

    SmokePerl::MethodCall methodCall(matches[0].first[0], self, SP - items + 2);
    XCPT_TRY_START {
        // This call could cause some other call to die or croak.  die and
        // croak are implemented with longjmp.  longjmp will bypass the normal
        // execution of C++ destructors, so...
        methodCall.next();
    } XCPT_TRY_END
    XCPT_CATCH {
        // ... we have to call them manually.
        methodCall.~MethodCall();
        matches.~vector<SmokePerl::MethodMatch>();
        XCPT_RETHROW;
    }

    ST(0) = sv_2mortal(methodCall.var());
    if (isConstructor) {
        SmokePerl::Object* object = SmokePerl::Object::fromSV(ST(0));
        object->ownership = SmokePerl::Object::ScriptOwnership;
        sv_bless(ST(0), stash);
    }

    if (gv) {
        SmokePerl::SmokeManager::instance().setInVirtualSuperCall("");
    }
    XSRETURN(1);
}

XS(XS_CAN) {
    dXSARGS;
    const char* methodName = SvPVX(ST(1));
    SV* self = ST(0);
    Smoke::ModuleIndex classId;
    HV* stash;

    if (SvTYPE(self) == SVt_PV) {
        const char* package = SvPVX(self);
        stash = gv_stashpv(package, 0);
        std::string className = SmokePerl::SmokeManager::instance().getClassForPackage(package);
        if (className == "") {
            AV* mro = mro_get_linear_isa(stash);
            for (int i=0; i < av_len(mro), className == ""; ++i) {
                SV** item = av_fetch(mro, i, 0);
                className = SmokePerl::SmokeManager::instance().getClassForPackage(SvPV_nolen(*item));
            }
        }
        classId = Smoke::findClass(className.c_str());
    }
    else {
        // self must be a reference
        stash = SvSTASH(SvRV(self));
        SmokePerl::Object* obj = SmokePerl::Object::fromSV(self);
        if (obj == nullptr)
            XSRETURN(0);
        classId = obj->classId;
    }

    // See if there's a perl method with this name
    GV* gv = gv_fetchmethod_autoload(stash, methodName, 0);
    if (!gv) {
        const char* className = classId.smoke->classes[classId.index].className;

        bool isConstructor = strcmp(methodName, "new") == 0;
        std::vector<std::string> args(1);
        if (isConstructor) {
            args[0] = className;
        }
        else {
            args[0] = methodName;
        }
        Smoke::ModuleIndex methodId = classId.smoke->findMethodName(className, isConstructor ? className : methodName);

        if (methodId != Smoke::NullModuleIndex) {
            gv = gv_fetchmethod_autoload(stash, methodName, 1);
        }
    }

    if (gv) {
        ENTER;
        SAVETMPS;
        PUSHMARK(SP);
        XPUSHs(sv_2mortal(newSVpv("SmokePerl::Method", 0)));
        XPUSHs(self);
        XPUSHs(sv_2mortal(newSVpv(methodName, 0)));
        XPUSHs(sv_2mortal(newRV((SV*)GvCV(gv))));
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
    XSRETURN(0);
}

XS(XS_DESTROY) {
}
