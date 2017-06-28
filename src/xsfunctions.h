#ifndef SMOKEPERL_AUTOLOAD
#define SMOKEPERL_AUTOLOAD

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

#include "undoXsubDefines.h"

XS(XS_AUTOLOAD);
XS(XS_CAN);
XS(XS_DESTROY);

#endif
