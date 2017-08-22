#include <qtxmlpatterns_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtXmlPatterns);
XS_EXTERNAL(boot_PerlQt5__PerlQtXmlPatterns)
{
    boot_PerlQt5__QtXmlPatterns(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtXmlPatterns PACKAGE = PerlQt5::QtXmlPatterns

BOOT:
    init_qtxmlpatterns_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtxmlpatterns_Smoke, "PerlQt5::QtXmlPatterns");
