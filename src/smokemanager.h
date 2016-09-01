#ifndef SMOKEPERL_SMOKEMANAGER
#define SMOKEPERL_SMOKEMANAGER

#include <map>
#include <string>

#include <smoke.h>

namespace SmokePerl {
class SmokeManager {
public:
    static SmokeManager& instance() {
        static SmokeManager instance;
        return instance;
    }

    void addSmokeModule(Smoke* smoke, const std::string& nspace);

    Smoke* getSmokeForPackage(const std::string& package) const;
    std::string getClassForPackage(const std::string& package) const;

    SmokeManager(SmokeManager const&) = delete;
    void operator=(SmokeManager const&) = delete;
private:
    SmokeManager() {};
    std::map<std::string, Smoke*> packageToSmoke;
    std::map<std::string, std::string> perlPackageToCClass;
};

}

#endif
