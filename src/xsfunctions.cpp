#include <iostream>

#include "xsfunctions.h"
#include "methodresolution.h"
#include "smokemanager.h"
#include "smokeobject.h"
#include "methodcall.h"

XS(XS_AUTOLOAD) {
    dXSARGS;
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
        croak("Unable to resolve method.");
    }
    SmokePerl::MethodCall methodCall(matches[0].first[0], self, SP - items + 2);
    methodCall.next();
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
    GV* perlSub = gv_fetchmethod_autoload(stash, methodName, 0);
    if (perlSub) {
        ST(0) = newRV_noinc((SV*)GvCV(perlSub));
        XSRETURN(1);
    }

    const char* className = classId.smoke->classes[classId.index].className;

    bool isConstructor = strcmp(methodName, "new") == 0;
    Smoke::ModuleIndex method = classId.smoke->findMethodName(className, isConstructor ? className : methodName);

    if (method.index) {
        GV* autoload = gv_fetchmethod_autoload(stash, methodName, 1);
        ST(0) = newRV_noinc((SV*)GvCV(autoload));
        XSRETURN(1);
    }
    XSRETURN(0);
}
