#include <iostream>
#include <string>

extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

#include "smokemanager.h"
#include "xsfunctions.h"

namespace SmokePerl {

void SmokeManager::addSmokeModule(Smoke* smoke, const std::string& nspace) {
    packageToSmoke[nspace] = smoke;
    for (int i = 1; i < smoke->numClasses; ++i) {
        const Smoke::Class& klass = smoke->classes[i];
        if (!klass.external) {
            std::string perlClassName = nspace + "::" + klass.className;
            packageToSmoke[perlClassName] = smoke;
            perlPackageToCClass[perlClassName] = klass.className;

            // Set AUTOLOAD method
            std::string autoload = perlClassName + "::AUTOLOAD";
            newXS(autoload.c_str(), XS_AUTOLOAD, __FILE__);

            // Set can method for this class
            std::string can = perlClassName + "::can";
            newXS(can.c_str(), XS_CAN, __FILE__);

            // Set ISA array
            std::string isaName = perlClassName + "::ISA";
            AV* isa = get_av(isaName.c_str(), true);
            Smoke::Index* parents = smoke->inheritanceList + klass.parents;
            while (*parents) {
                av_push(isa, newSVpv((nspace + "::" + smoke->classes[*parents++].className).c_str(), 0));
            }
        }
    }
}

Smoke* SmokeManager::getSmokeForPackage(const std::string& package) const {
    if (!packageToSmoke.count(package))
        return nullptr;
    return packageToSmoke.at(package);
}

std::string SmokeManager::getClassForPackage(const std::string& package) const {
    if (!perlPackageToCClass.count(package))
        return "";
    return perlPackageToCClass.at(package);
}

}
