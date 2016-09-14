#include <smoketestlib_smoke.h>
#include "smokemanager.h"

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

MODULE = PerlSmokeTest PACKAGE = PerlSmokeTest

BOOT:
    init_smoketestlib_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(smoketestlib_Smoke, "PerlSmokeTest");
