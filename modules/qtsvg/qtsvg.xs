#include <qtsvg_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtSvg);
XS_EXTERNAL(boot_PerlQt5__PerlQtSvg)
{
    boot_PerlQt5__QtSvg(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtSvg PACKAGE = PerlQt5::QtSvg

BOOT:
    init_qtsvg_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtsvg_Smoke, "PerlQt5::QtSvg");
