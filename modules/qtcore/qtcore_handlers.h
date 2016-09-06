#ifndef SMOKEPERL_QTCORE_HANDLERS
#define SMOKEPERL_QTCORE_HANDLERS

#include <string>
#include <unordered_map>

#include "marshall.h"

extern std::unordered_map<std::string, SmokePerl::Marshall::HandlerFn> qtcore_typeHandlers;

void marshall_QString(SmokePerl::Marshall* m);

#endif
