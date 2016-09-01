#ifndef SMOKEPERL_METHODRESOLUTION
#define SMOKEPERL_METHODRESOLUTION

#include <string>
#include <vector>

#include <smoke.h>

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

namespace SmokePerl {

std::vector<Smoke::ModuleIndex> findCandidates(Smoke::ModuleIndex classId, const std::vector<std::string>& mungedMethods);
std::vector<std::string> mungedMethods(const std::string& methodName, int argc, SV** args);

}

#endif
