#include <qtmultimediawidgets_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtMultimediaWidgets);
XS_EXTERNAL(boot_PerlQt5__PerlQtMultimediaWidgets)
{
    boot_PerlQt5__QtMultimediaWidgets(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtMultimediaWidgets PACKAGE = PerlQt5::QtMultimediaWidgets

BOOT:
    init_qtmultimediawidgets_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtmultimediawidgets_Smoke, "PerlQt5::QtMultimediaWidgets");
