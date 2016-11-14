#include <iostream>

#include "smokebinding.h"
#include "smokemanager.h"
#include "smokeobject.h"
#include "virtualmethodcall.h"

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

namespace SmokePerl {

char* SmokePerlBinding::className(Smoke::Index classId) {
    if (classNameMap.count(classId) == 0) {
        std::string pkg = SmokePerl::SmokeManager::instance().getPackageForSmoke(smoke);
        pkg += "::";
        pkg += smoke->className(classId);
        classNameMap[classId] = pkg;
    }
    return const_cast<char*>(classNameMap.at(classId).c_str());
}

bool SmokePerlBinding::callMethod(Smoke::Index method, void* ptr, Smoke::Stack args, bool isAbstract) {
    PERL_SET_CONTEXT(PL_curinterp);

    SmokePerl::Object* obj = SmokePerl::ObjectMap::instance().get(ptr);

    if (obj == nullptr || !obj->isValid())
        return false;

    SV* self = obj->sv;
    if (self == nullptr || !SvOK(self) || !SvROK(self))
        return false;

    SV* rv = SvRV(self);
    if (rv == nullptr)
        return false;

    HV* stash = SvSTASH(rv);
    const char* methodName = smoke->methodNames[smoke->methods[method].name];

    // If this virtual method call came from a Perl method that went through
    // XS_AUTOLOAD, it is possible that this virtual method call is a result of
    // calling package->SUPER::method().  If the current method being called
    // from XS_AUTOLOAD is the same as the method we're about to call, then
    // that would lead to infinite recursion.  Break out of the recursion in
    // this case.
    if (SmokePerl::SmokeManager::instance().inVirtualSuperCall() == std::string(smoke->classes[obj->classId.index].className) + "::" + methodName) {
        return false;
    }

    GV* gv = gv_fetchmethod_autoload(stash, methodName, 0);

    if (!gv) {
        if (isAbstract) {
            Smoke::Method methodobj = smoke->methods[method];
            croak("%s: %s::%s",
                "Unimplemented pure virtual method called",
                HvNAME(stash),
                methodName
            );
        }
        return false;
    }

    VirtualMethodCall methodCall(Smoke::ModuleIndex(smoke, method), args, self, gv);
    methodCall.next();

    return true;
}

void SmokePerlBinding::deleted(Smoke::Index classId, void* cxxptr) {
    SmokePerl::Object* obj = SmokePerl::ObjectMap::instance().get(cxxptr);

    if (obj == nullptr || !obj->isValid()) {
        return;
    }

    SmokePerl::ObjectMap::instance().remove(obj, obj->classId);
    obj->invalidate();

    return;
}

}
