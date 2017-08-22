#include <qtwebchannel_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtWebChannel);
XS_EXTERNAL(boot_PerlQt5__PerlQtWebChannel)
{
    boot_PerlQt5__QtWebChannel(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtWebChannel PACKAGE = PerlQt5::QtWebChannel

BOOT:
    init_qtwebchannel_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtwebchannel_Smoke, "PerlQt5::QtWebChannel");
