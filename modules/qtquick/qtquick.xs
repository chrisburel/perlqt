#include <qtquick_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtQuick);
XS_EXTERNAL(boot_PerlQt5__PerlQtQuick)
{
    boot_PerlQt5__QtQuick(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtQuick PACKAGE = PerlQt5::QtQuick

BOOT:
    init_qtquick_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtquick_Smoke, "PerlQt5::QtQuick");
