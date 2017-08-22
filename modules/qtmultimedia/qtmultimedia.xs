#include <qtmultimedia_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtMultimedia);
XS_EXTERNAL(boot_PerlQt5__PerlQtMultimedia)
{
    boot_PerlQt5__QtMultimedia(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtMultimedia PACKAGE = PerlQt5::QtMultimedia

BOOT:
    init_qtmultimedia_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtmultimedia_Smoke, "PerlQt5::QtMultimedia");
