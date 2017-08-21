#include <qtwebenginecore_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtWebEngineCore);
XS_EXTERNAL(boot_PerlQt5__PerlQtWebEngineCore)
{
    boot_PerlQt5__QtWebEngineCore(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtWebEngineCore PACKAGE = PerlQt5::QtWebEngineCore

BOOT:
    init_qtwebenginecore_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtwebenginecore_Smoke, "PerlQt5::QtWebEngineCore");
