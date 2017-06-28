#ifndef SMOKEPERL_AUTOLOAD
#define SMOKEPERL_AUTOLOAD

#include "smokeperl_export.h"

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

#include "undoXsubDefines.h"

XS(XS_AUTOLOAD);
SMOKEPERL_EXPORT XSPROTO(XS_CAN);
XS(XS_DESTROY);

#endif
