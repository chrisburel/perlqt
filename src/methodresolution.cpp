#include "methodresolution.h"
#include "smokeobject.h"

namespace SmokePerl {

std::vector<Smoke::ModuleIndex> findCandidates(Smoke::ModuleIndex classId, const std::vector<std::string>& mungedMethods) {
    Smoke::Class& klass = classId.smoke->classes[classId.index];
    std::vector<Smoke::ModuleIndex> methodIds;

    for (const auto& mungedMethod : mungedMethods) {
        Smoke::ModuleIndex methodId = classId.smoke->findMethod(klass.className, mungedMethod.c_str());

        if (methodId.index != 0)
            methodIds.push_back(methodId);
    }

    std::vector<Smoke::ModuleIndex> candidates;

    for (const auto& methodId : methodIds) {
        Smoke::Index ix = methodId.smoke->methodMaps[methodId.index].method;
        Smoke::ModuleIndex mi;
        if (ix == 0) {
        }
        else if (ix > 0) {
            mi.index = ix;
            mi.smoke = methodId.smoke;
            candidates.push_back(mi);
        }
        else if (ix < 0) {
            ix = -ix;
            while (methodId.smoke->ambiguousMethodList[ix] != 0) {
                mi.index = methodId.smoke->ambiguousMethodList[ix];
                mi.smoke = methodId.smoke;
                candidates.push_back(mi);
                ix++;
            }
        }
    }

    return candidates;
}
std::vector<std::string> mungedMethods(const std::string& methodName, int argc, SV** args) {
    std::vector<std::string> result;
    result.push_back(methodName);

    for (int i=0; i < argc; ++i) {
        SV* value = args[i];

        if (SvTYPE(value) == SVt_NULL) {
            std::vector<std::string> temp;
            for (const auto& mungedMethod : result) {
                temp.push_back(mungedMethod + '$');
                temp.push_back(mungedMethod + '?');
                temp.push_back(mungedMethod + '#');
            }
            result = temp;
        }
        else if (SmokePerl::Object::fromSV(value) != nullptr) {
            for (auto& mungedMethod : result) {
                mungedMethod += '#';
            }
        }
        else if (SvROK(value) && (SvTYPE(SvRV(value)) == SVt_PVAV || SvTYPE(SvRV(value)) == SVt_PVHV)) {
            for (auto& mungedMethod : result) {
                mungedMethod += '?';
            }
        }
        else {
            for (auto& mungedMethod : result) {
                mungedMethod += '$';
            }
        }
    }
    return result;
}

}
