#include "methodresolution.h"
#include "smokeobject.h"

namespace SmokePerl {

static std::string typeName(const Smoke::Type& typeRef) {
    std::string name(typeRef.name);
    if (name.find("const ") != std::string::npos) {
        name.replace(0, 5, "");
    }
    if (const auto pos = name.find("&") != std::string::npos) {
        name.replace(pos, 1, "");
    }
    if (const auto pos = name.find("*") != std::string::npos) {
        name.replace(pos, 1, "");
    }
    return name;
}

static int matchArgument(SV* actual, const Smoke::Type& typeRef) {
    std::string fullArgType(typeRef.name);
    if (fullArgType.find("const ") != std::string::npos) {
        fullArgType.replace(0, 5, "");
    }
    std::string argType = typeName(typeRef);
    int matchDistance = 0;

    if (SvROK(actual)) {
        actual = SvRV(actual);
    }
    if (SvTYPE(actual) == SVt_IV) {
        switch (typeRef.flags & Smoke::tf_elem) {
            case Smoke::t_int:
                break;
            case Smoke::t_long:
                matchDistance += 1;
                break;
            case Smoke::t_short:
                matchDistance += 2;
                break;
            case Smoke::t_enum:
                matchDistance += 3;
                break;
            case Smoke::t_ulong:
                matchDistance += 4;
                break;
            case Smoke::t_uint:
                matchDistance += 5;
                break;
            case Smoke::t_ushort:
                matchDistance += 6;
                break;
            case Smoke::t_char:
                matchDistance += 7;
                break;
            case Smoke::t_uchar:
                matchDistance += 8;
                break;
            default:
                matchDistance += 100;
        }
    }
    else if (SvTYPE(actual) == SVt_NV) {
        switch (typeRef.flags & Smoke::tf_elem) {
            case Smoke::t_double:
                break;
            case Smoke::t_float:
                matchDistance += 1;
                break;
            default:
                matchDistance += 100;
        }
    }
    else if (actual == &PL_sv_yes || actual == &PL_sv_no) {
        if ((typeRef.flags & Smoke::tf_elem) == Smoke::t_bool) {
        }
        else {
            matchDistance += 100;
        }
    }

    return matchDistance;
}

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

        SmokePerl::Object* obj = SmokePerl::Object::fromSV(value);
        if (SvTYPE(value) == SVt_NULL) {
            std::vector<std::string> temp;
            for (const auto& mungedMethod : result) {
                temp.push_back(mungedMethod + '$');
                temp.push_back(mungedMethod + '?');
                temp.push_back(mungedMethod + '#');
            }
            result = temp;
        }
        else if (obj != nullptr && obj->classId != Smoke::NullModuleIndex) {
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

MethodMatches resolveMethod(Smoke::ModuleIndex classId, const std::string& methodName, int argc, SV** args) {
    const auto mungedMethods = SmokePerl::mungedMethods(methodName, argc, args);
    const auto candidates = SmokePerl::findCandidates(classId, mungedMethods);

    MethodMatches matches;

    for (const auto& method : candidates) {
        Smoke::Method& methodRef = method.smoke->methods[method.index];

        if ((methodRef.flags & Smoke::mf_internal) == 0) {
            std::vector<Smoke::ModuleIndex> methods {method};
            int matchDistance = 0;

            // If a method is overloaded only on const-ness, prefer the
            // non-const version
            if (methodRef.flags & Smoke::mf_const) {
                matchDistance += 1;
            }

            for (int i = 0; i < methodRef.numArgs; ++i) {
                SV* actual = args[i];
                unsigned short argFlags = method.smoke->types[method.smoke->argumentList[methodRef.args+i]].flags;
                int distance = matchArgument(actual, method.smoke->types[method.smoke->argumentList[methodRef.args+i]]);

                matchDistance += distance;
            }

            auto insertPos = matches.end();
            if (matches.size() > 0 && matchDistance <= matches[0].second) {
                insertPos = matches.begin();
            }
            matches.insert(insertPos, MethodMatch(methods, matchDistance));
        }
    }

    return matches;
}

}
