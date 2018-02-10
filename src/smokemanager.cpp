#include <iostream>
#include <string>

extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

#include "undoXsubDefines.h"

#include "smokebinding.h"
#include "smokemanager.h"
#include "xsfunctions.h"

namespace SmokePerl {

SmokeManager::~SmokeManager() {
    for (const auto& pair : smokeToBinding) {
        delete pair.second;
    }
}

SmokeManager::SmokeManager() {
    eval_pv("use SmokePerl;", true);
}

SmokeManager& SmokeManager::instance() {
    static SmokeManager instance;
    return instance;
}

void SmokeManager::addSmokeModule(Smoke* smoke, const std::string& nspace) {
    packageToSmoke[nspace] = smoke;
    smokeToPackage[smoke] = nspace;
    smokeToBinding[smoke] = new SmokePerlBinding(smoke);
    for (int i = 1; i <= smoke->numClasses; ++i) {
        const Smoke::Class& klass = smoke->classes[i];
        if (!klass.external) {
            std::string perlClassName = nspace + "::" + klass.className;
            packageToSmoke[perlClassName] = smoke;
            perlPackageToCClass[perlClassName] = klass.className;

            if (klass.parents == 0) {
                // Set AUTOLOAD method
                std::string autoload = perlClassName + "::AUTOLOAD";
                newXS(autoload.c_str(), XS_AUTOLOAD, __FILE__);

                // Set can method for this class
                std::string can = perlClassName + "::can";
                newXS(can.c_str(), XS_CAN, __FILE__);

                // Set DESTROY method
                std::string destroy = perlClassName + "::DESTROY";
                newXS(destroy.c_str(), XS_DESTROY, __FILE__);
            }

            // Set ISA array
            std::string isaName = perlClassName + "::ISA";
            AV* isa = get_av(isaName.c_str(), true);
            for (Smoke::Index* parent = smoke->inheritanceList + klass.parents; *parent != 0; ++parent) {
                char* className;
                if (smoke->classes[*parent].external) {
                    Smoke::ModuleIndex mi = Smoke::findClass(smoke->classes[*parent].className);
                    if (mi != Smoke::NullModuleIndex) {
                        className = getBindingForSmoke(mi.smoke)->className(mi.index);
                    }
                }
                else {
                    className = getBindingForSmoke(smoke)->className(*parent);
                }
                av_push(isa, newSVpv(className, 0));
            }
        }
    }
    for (int i = 1; i < smoke->numTypes; ++i) {
        const Smoke::Type& curType = smoke->types[i];
        if ((curType.flags & Smoke::tf_elem) == Smoke::t_enum) {
            const std::string perlClassName = nspace + "::" + curType.name;
            perlPackageToCClass[perlClassName] = curType.name;
        }
    }
}

SmokePerlBinding* SmokeManager::getBindingForSmoke(Smoke* smoke) const {
    if (!smokeToBinding.count(smoke))
        return nullptr;
    return smokeToBinding.at(smoke);
}

std::string SmokeManager::getClassForPackage(const std::string& package) const {
    if (!perlPackageToCClass.count(package))
        return "";
    return perlPackageToCClass.at(package);
}

std::string SmokeManager::getPackageForSmoke(Smoke* smoke) const {
    if (!smokeToPackage.count(smoke))
        return "";
    return smokeToPackage.at(smoke);
}

Smoke* SmokeManager::getSmokeForPackage(const std::string& package) const {
    if (!packageToSmoke.count(package))
        return nullptr;
    return packageToSmoke.at(package);
}

const std::vector<Smoke*> SmokeManager::getSmokes() const {
    std::vector<Smoke*> keys;
    for (const auto& pair : smokeToBinding) {
        keys.push_back(pair.first);
    }
    return keys;
}

}
