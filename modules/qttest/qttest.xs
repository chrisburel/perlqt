#include <qttest_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtTest);
XS_EXTERNAL(boot_PerlQt5__PerlQtTest)
{
    boot_PerlQt5__QtTest(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtTest PACKAGE = PerlQt5::QtTest

BOOT:
    init_qttest_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qttest_Smoke, "PerlQt5::QtTest");
