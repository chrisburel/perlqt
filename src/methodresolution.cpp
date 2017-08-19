#include <algorithm>
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

static int matchArgument(SV* actual, const Smoke::ModuleIndex& baseClassId, const Smoke::Type& typeRef) {
    std::string fullArgType(typeRef.name);
    if (fullArgType.find("const ") != std::string::npos) {
        fullArgType.replace(0, 5, "");
    }
    std::string argType = typeName(typeRef);
    int matchDistance = 0;

    Object* object = Object::fromSV(actual);

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
    else if (SvTYPE(actual) == SVt_PVHV || SvTYPE(actual) == SVt_PVAV) {
        if ((typeRef.flags & Smoke::tf_elem) == Smoke::t_class) {
            if (object && object->isValid()) {
                matchDistance += object->inheritanceDistance(baseClassId);
            }
            else {
                matchDistance = -1;
            }
        }
        else if ((typeRef.flags & Smoke::tf_elem) == Smoke::t_voidp && object && object->isValid() && object->classId == Smoke::NullModuleIndex) {
            // This is the case when the arg is a void**, as used by methods
            // like qt_metacall
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
        if (!SvOK(value)) {
            // value is undef.  undef can be anything, so add all possible
            // signatures and figure it out later
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

            bool allArgTypesCompatible = true;
            for (int i = 0; i < methodRef.numArgs; ++i) {
                SV* actual = args[i];
                const Smoke::Type& type = method.smoke->types[method.smoke->argumentList[methodRef.args+i]];
                const int distance = matchArgument(
                    actual,
                    {method.smoke, type.classId},
                    type
                );

                if (distance == -1) {
                    allArgTypesCompatible = false;
                    break;
                }

                matchDistance += distance;
            }

            if (!allArgTypesCompatible)
                continue;

            matches.push_back(MethodMatch(methods, matchDistance));
        }
    }

    // Sort the array of matches based on their score.  Use a stable sort so
    // that order is preserved.  The order that is defined in the smoke object
    // should be the order in which the methods were declaraed in the source
    // header.
    std::stable_sort(matches.begin(), matches.end(), [](const MethodMatch& lhs, const MethodMatch& rhs) {
        return lhs.second < rhs.second;
    });
    return matches;
}

}
