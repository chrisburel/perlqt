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
    std::string pkg = SmokePerl::SmokeManager::instance().getPackageForSmoke(smoke);
    pkg += "::";
    pkg += smoke->className(classId);
    return const_cast<char*>(pkg.c_str());
}

bool SmokePerlBinding::callMethod(Smoke::Index method, void* ptr, Smoke::Stack args, bool isAbstract) {
    PERL_SET_CONTEXT(PL_curinterp);

    SmokePerl::Object* obj = SmokePerl::ObjectMap::instance().get(ptr);

    if (obj == nullptr)
        return false;

    SV* self = obj->sv;
    if (self == nullptr || !SvOK(self) || !SvROK(self))
        return false;

    SV* rv = SvRV(self);
    if (rv == nullptr)
        return false;

    HV* stash = SvSTASH(rv);
    const char* methodName = smoke->methodNames[smoke->methods[method].name];

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

void SmokePerlBinding::deleted(Smoke::Index classId, void* obj) {
}

}
