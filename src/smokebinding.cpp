#include "smokebinding.h"
#include "smokemanager.h"

namespace SmokePerl {

char* SmokePerlBinding::className(Smoke::Index classId) {
    std::string pkg = SmokePerl::SmokeManager::instance().getPackageForSmoke(smoke);
    pkg += "::";
    pkg += smoke->className(classId);
    return const_cast<char*>(pkg.c_str());
}

bool SmokePerlBinding::callMethod(Smoke::Index method, void* obj, Smoke::Stack args, bool isAbstract) {
    return false;
}

void SmokePerlBinding::deleted(Smoke::Index classId, void* obj) {
}

}
