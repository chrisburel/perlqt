#include <qtpositioning_smoke.h>
#include "smokemanager.h"

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

#ifdef _MSC_VER
#undef XS_EXTERNAL
#define XS_EXTERNAL(name) extern "C" __declspec(dllexport) XSPROTO(name)

XS_EXTERNAL(boot_PerlQt5__QtPositioning);
XS_EXTERNAL(boot_PerlQt5__PerlQtPositioning)
{
    boot_PerlQt5__QtPositioning(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtPositioning PACKAGE = PerlQt5::QtPositioning

BOOT:
    init_qtpositioning_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtpositioning_Smoke, "PerlQt5::QtPositioning");
