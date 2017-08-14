#include <qtsql_smoke.h>
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

XS_EXTERNAL(boot_PerlQt5__QtSql);
XS_EXTERNAL(boot_PerlQt5__PerlQtSql)
{
    boot_PerlQt5__QtSql(aTHX_ cv);
}
#endif

MODULE = PerlQt5::QtSql PACKAGE = PerlQt5::QtSql

BOOT:
    init_qtsql_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtsql_Smoke, "PerlQt5::QtSql");
