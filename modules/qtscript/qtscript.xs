#include <qtscript_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtScript);
XS_EXTERNAL(boot_PerlQt5__PerlQtScript)
{
    boot_PerlQt5__QtScript(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtScript PACKAGE = PerlQt5::QtScript

BOOT:
    init_qtscript_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtscript_Smoke, "PerlQt5::QtScript");
