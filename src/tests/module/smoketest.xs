#include <smoketestlib_smoke.h>
#include "smokemanager.h"

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

#include "undoXsubDefines.h"

#ifdef _MSC_VER
#undef XS_EXTERNAL
#define XS_EXTERNAL(name) extern "C" __declspec(dllexport) XSPROTO(name)
#endif

MODULE = PerlSmokeTest PACKAGE = PerlSmokeTest

BOOT:
    init_smoketestlib_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(smoketestlib_Smoke, "PerlSmokeTest");
