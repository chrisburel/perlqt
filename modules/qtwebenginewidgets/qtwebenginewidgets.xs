#include <qtwebenginewidgets_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtWebEngineWidgets);
XS_EXTERNAL(boot_PerlQt5__PerlQtWebEngineWidgets)
{
    boot_PerlQt5__QtWebEngineWidgets(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtWebEngineWidgets PACKAGE = PerlQt5::QtWebEngineWidgets

BOOT:
    init_qtwebenginewidgets_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtwebenginewidgets_Smoke, "PerlQt5::QtWebEngineWidgets");
