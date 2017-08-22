#include <qtdbus_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtDBus);
XS_EXTERNAL(boot_PerlQt5__PerlQtDBus)
{
    boot_PerlQt5__QtDBus(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtDBus PACKAGE = PerlQt5::QtDBus

BOOT:
    init_qtdbus_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtdbus_Smoke, "PerlQt5::QtDBus");
