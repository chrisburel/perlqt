#include <qtprintsupport_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtPrintSupport);
XS_EXTERNAL(boot_PerlQt5__PerlQtPrintSupport)
{
    boot_PerlQt5__QtPrintSupport(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtPrintSupport PACKAGE = PerlQt5::QtPrintSupport

BOOT:
    init_qtprintsupport_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtprintsupport_Smoke, "PerlQt5::QtPrintSupport");
