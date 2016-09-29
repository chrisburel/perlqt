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
    bool isConstructor = strcmp(methodName, "new") == 0;
    if (isConstructor) {
        methodName = className.c_str();
    }

    SV* self = ST(0);
    Smoke::ModuleIndex classId;
    if (SvTYPE(self) == SVt_PV) {
        classId = Smoke::findClass(className.c_str());
    }
    else if (SvROK(self) && SvTYPE(SvRV(self)) == SVt_PVHV) {
        SmokePerl::Object* obj = SmokePerl::Object::fromSV(self);
        if (obj == nullptr)
            XSRETURN(0);
        classId = obj->classId;
    }
    SmokePerl::MethodMatches matches = SmokePerl::resolveMethod(classId, methodName, items - 1, SP - items + 2);

    if (matches.size() == 0) {
        croak("Unable to resolve method.");
    }
    SmokePerl::MethodCall methodCall(matches[0].first[0], self, SP - items + 2);
    methodCall.next();
    ST(0) = sv_2mortal(methodCall.var());
    if (isConstructor) {
        SmokePerl::Object* object = SmokePerl::Object::fromSV(ST(0));
        object->ownership = SmokePerl::Object::ScriptOwnership;
    }
    XSRETURN(1);
}

XS(XS_CAN) {
    dXSARGS;
    const char* methodName = SvPVX(ST(1));
    const char* package;
    SV* self = ST(0);
    if (SvTYPE(self) == SVt_PV) {
       package = SvPVX(self);
    }
    else {
        if (!SvROK(self))
            XSRETURN(0);
        HV* stash = SvSTASH(SvRV(self));
        if (stash == nullptr)
            XSRETURN(0);
        package = HvNAME(stash);
    }
    Smoke* smoke = SmokePerl::SmokeManager::instance().getSmokeForPackage(package);
    if (smoke == nullptr)
        XSRETURN(0);
    std::string className = SmokePerl::SmokeManager::instance().getClassForPackage(package);
    if (className == "")
        XSRETURN(0);
    bool isConstructor = strcmp(methodName, "new") == 0;
    Smoke::ModuleIndex method = smoke->findMethodName(className.c_str(), isConstructor ? className.c_str() : methodName);
    if (method.index) {
        HV* stash = gv_stashpv(package, 0);
        GV* autoload = gv_fetchmethod_autoload(stash, methodName, 1);
        if (autoload) {
            ST(0) = newRV_noinc((SV*)GvCV(autoload));
            XSRETURN(1);
        }
    }
    XSRETURN(0);
}
