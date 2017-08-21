#include <qtuitools_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtUiTools);
XS_EXTERNAL(boot_PerlQt5__PerlQtUiTools)
{
    boot_PerlQt5__QtUiTools(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtUiTools PACKAGE = PerlQt5::QtUiTools

BOOT:
    init_qtuitools_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtuitools_Smoke, "PerlQt5::QtUiTools");
