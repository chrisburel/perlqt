#ifndef SMOKETESTLIB_SMOKE_H
#define SMOKETESTLIB_SMOKE_H

#include <smoke.h>

// Defined in smokedata.cpp, initialized by init_qtcore_Smoke(), used by all
// .cpp files
extern "C" SMOKE_EXPORT Smoke* smoketestlib_Smoke;
extern "C" SMOKE_EXPORT void init_smoketestlib_Smoke();
extern "C" SMOKE_EXPORT void delete_smoketestlib_Smoke();

#endif
