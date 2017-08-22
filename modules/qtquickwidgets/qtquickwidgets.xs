#include <qtquickwidgets_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtQuickWidgets);
XS_EXTERNAL(boot_PerlQt5__PerlQtQuickWidgets)
{
    boot_PerlQt5__QtQuickWidgets(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtQuickWidgets PACKAGE = PerlQt5::QtQuickWidgets

BOOT:
    init_qtquickwidgets_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtquickwidgets_Smoke, "PerlQt5::QtQuickWidgets");
