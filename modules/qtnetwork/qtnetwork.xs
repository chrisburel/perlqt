#include <qtnetwork_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtNetwork);
XS_EXTERNAL(boot_PerlQt5__PerlQtNetwork)
{
    boot_PerlQt5__QtNetwork(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtNetwork PACKAGE = PerlQt5::QtNetwork

BOOT:
    init_qtnetwork_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtnetwork_Smoke, "PerlQt5::QtNetwork");
