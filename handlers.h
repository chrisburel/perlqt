#ifndef HANDLERS_H
#define HANDLERS_H

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include "smokeperl.h"
#include "marshall.h"

struct TypeHandler {
    const char *name;
    Marshall::HandlerFn fn;
};

void marshall_QString(Marshall *m);
void marshall_basetype(Marshall *m);
void marshall_void(Marshall *m);

void install_handlers(TypeHandler *h);

Marshall::HandlerFn getMarshallFn(const SmokeType &type);

#endif // HANDLERS_H
