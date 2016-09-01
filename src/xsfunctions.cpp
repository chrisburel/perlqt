#include <iostream>

#include "xsfunctions.h"
#include "methodresolution.h"
#include "smokemanager.h"

XS(XS_AUTOLOAD) {
    dXSARGS;
    HV* stash = CvSTASH(cv);
    const char* package = HvNAME(stash);
    const char* methodName = SvPVX(cv);

    std::string className = SmokePerl::SmokeManager::instance().getClassForPackage(package);
    AV* mro = mro_get_linear_isa(stash);
    for (int i=0; i < av_len(mro), className == ""; ++i) {
        SV** item = av_fetch(mro, i, 0);
        if (item) {
            className = SmokePerl::SmokeManager::instance().getClassForPackage(SvPV_nolen(*item));
        }
    }
    if (strcmp(methodName, "new") == 0) {
        methodName = className.c_str();
    }

    SV* self = ST(0);
    Smoke::ModuleIndex classId;
    if (SvTYPE(self) == SVt_PV) {
        Smoke* smoke = SmokePerl::SmokeManager::instance().getSmokeForPackage(package);
        if (smoke == nullptr)
            XSRETURN(0);
        classId = smoke->findClass(className.c_str());
    }
    std::cout << "In AUTOLOAD for " << package << "    " << className << "::" << methodName << "    " << items << std::endl;
    std::vector<std::string> mungedMethods = SmokePerl::mungedMethods(methodName, items - 1, SP - items + 2);
    std::vector<Smoke::ModuleIndex> candidates = SmokePerl::findCandidates(classId, mungedMethods);
    if (candidates.size() != 1) {
        croak("Unable to call overloaded method");
    }
    XSRETURN(0);
}

XS(XS_CAN) {
    dXSARGS;
    const char* methodName = SvPVX(POPs);
    const char* package = SvPVX(POPs);
    Smoke* smoke = SmokePerl::SmokeManager::instance().getSmokeForPackage(package);
    if (smoke == nullptr)
        XSRETURN(0);
    std::string className = SmokePerl::SmokeManager::instance().getClassForPackage(package);
    if (className == "")
        XSRETURN(0);
    if (strcmp(methodName, "new") == 0) {
        methodName = className.c_str();
    }
    Smoke::ModuleIndex method = smoke->findMethodName(className.c_str(), methodName);
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
