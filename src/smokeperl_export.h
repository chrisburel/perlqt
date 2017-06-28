#ifndef SMOKEPERL_EXPORT_H
#define SMOKEPERL_EXPORT_H

#if defined (_WIN32)
    #if defined(smokeperl_EXPORTS)
        #define SMOKEPERL_EXPORT __declspec(dllexport)
    #else
        #define SMOKEPERL_EXPORT __declspec(dllimport)
    #endif
#else
    #define SMOKEPERL_EXPORT
#endif

#endif
