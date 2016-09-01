#include <QDebug>

#include <qtcore_smoke.h>
#include "smokemanager.h"

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

MODULE = PerlQt5::QtCore PACKAGE = PerlQt5::QtCore

BOOT:
    init_qtcore_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtcore_Smoke, "PerlQt5::QtCore");
