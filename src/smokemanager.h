#ifndef SMOKEPERL_SMOKEMANAGER
#define SMOKEPERL_SMOKEMANAGER

#include <unordered_map>
#include <string>

#include <smoke.h>
#include "smokebinding.h"

namespace SmokePerl {
class SmokeManager {
public:
    static SmokeManager& instance() {
        static SmokeManager instance;
        return instance;
    }

    void addSmokeModule(Smoke* smoke, const std::string& nspace);
    SmokePerlBinding* getBindingForSmoke(Smoke* smoke) const;
    std::string getClassForPackage(const std::string& package) const;
    std::string getPackageForSmoke(Smoke* smoke) const;
    Smoke* getSmokeForPackage(const std::string& package) const;

    inline const std::string& inVirtualSuperCall() const {
        return m_inVirtualSuperCall;
    }

    inline void setInVirtualSuperCall(std::string newInVirtualSuperCall) {
        m_inVirtualSuperCall = newInVirtualSuperCall;
    }

    SmokeManager(SmokeManager const&) = delete;
    void operator=(SmokeManager const&) = delete;
private:
    SmokeManager() {};
    std::unordered_map<std::string, Smoke*> packageToSmoke;
    std::unordered_map<std::string, std::string> perlPackageToCClass;
    std::unordered_map<Smoke*, SmokePerlBinding*> smokeToBinding;
    std::unordered_map<Smoke*, std::string> smokeToPackage;

    std::string m_inVirtualSuperCall;
};

}

#endif
