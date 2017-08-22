#include <qtqml_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtQml);
XS_EXTERNAL(boot_PerlQt5__PerlQtQml)
{
    boot_PerlQt5__QtQml(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtQml PACKAGE = PerlQt5::QtQml

BOOT:
    init_qtqml_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtqml_Smoke, "PerlQt5::QtQml");
