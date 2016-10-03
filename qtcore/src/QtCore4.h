#ifndef QT_H
#define QT_H

#include "smokeperl.h"
#include "smokehelp.h"

//#define Q_DECL_EXPORT __attribute__ ((visibility("default")))

#ifdef PERLQTDEBUG
SV* catCallerInfo( int count );
#endif

extern SV* sv_this;
extern HV* pointer_map;
extern int do_debug;

#endif // QT_H
