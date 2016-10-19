#ifndef SMOKEPERL_HANDLERS
#define SMOKEPERL_HANDLERS

#include "marshall.h"

namespace SmokePerl {

void marshall_basetype(Marshall* m);
void marshall_unknown(Marshall* m);
void marshall_void(Marshall* m);

template <class T>
void marshall_PrimitiveRef(Marshall* m);

void marshall_CharPArray(Marshall* m);
void marshall_VoidPArray(Marshall* m);

}
#endif
