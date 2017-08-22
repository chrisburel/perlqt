#include <qtxml_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtXml);
XS_EXTERNAL(boot_PerlQt5__PerlQtXml)
{
    boot_PerlQt5__QtXml(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtXml PACKAGE = PerlQt5::QtXml

BOOT:
    init_qtxml_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtxml_Smoke, "PerlQt5::QtXml");
