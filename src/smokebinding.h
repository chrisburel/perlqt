#ifndef SMOKEPERL_SMOKEBINDING
#define SMOKEPERL_SMOKEBINDING

#include <unordered_map>
#include <string>

#include <smoke.h>

namespace SmokePerl {

class SmokePerlBinding : public SmokeBinding {
public:
    SmokePerlBinding() : SmokeBinding(0) {}
    SmokePerlBinding(Smoke* smoke) : SmokeBinding(smoke) {}
    virtual char* className(Smoke::Index classId);
    virtual bool callMethod(Smoke::Index method, void* ptr, Smoke::Stack args, bool isAbstract=false);
    virtual void deleted(Smoke::Index classId, void* obj);
private:
    std::unordered_map<Smoke::Index, std::string> classNameMap;
};

};

#endif
