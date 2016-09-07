#include <qtgui_smoke.h>
#include "smokemanager.h"

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

MODULE = PerlQt5::QtGui PACKAGE = PerlQt5::QtGui

BOOT:
    init_qtgui_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtgui_Smoke, "PerlQt5::QtGui");
