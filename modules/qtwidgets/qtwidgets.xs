#include <qtwidgets_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtWidgets);
XS_EXTERNAL(boot_PerlQt5__PerlQtWidgets)
{
    boot_PerlQt5__QtWidgets(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtWidgets PACKAGE = PerlQt5::QtWidgets

BOOT:
    init_qtwidgets_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtwidgets_Smoke, "PerlQt5::QtWidgets");
