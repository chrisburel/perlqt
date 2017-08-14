#include <qthelp_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtHelp);
XS_EXTERNAL(boot_PerlQt5__PerlQtHelp)
{
    boot_PerlQt5__QtHelp(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtHelp PACKAGE = PerlQt5::QtHelp

BOOT:
    init_qthelp_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qthelp_Smoke, "PerlQt5::QtHelp");
