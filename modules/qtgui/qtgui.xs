#include <qtgui_smoke.h>
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
#endif

MODULE = PerlQt5::QtGui PACKAGE = PerlQt5::QtGui

BOOT:
    init_qtgui_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtgui_Smoke, "PerlQt5::QtGui");
