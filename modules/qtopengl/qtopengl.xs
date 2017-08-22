#include <qtopengl_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtOpenGL);
XS_EXTERNAL(boot_PerlQt5__PerlQtOpenGL)
{
    boot_PerlQt5__QtOpenGL(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtOpenGL PACKAGE = PerlQt5::QtOpenGL

BOOT:
    init_qtopengl_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtopengl_Smoke, "PerlQt5::QtOpenGL");
