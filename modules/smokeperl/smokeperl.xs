#include "smokeobject.h"

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

#ifdef _MSC_VER
#undef XS_EXTERNAL
#define XS_EXTERNAL(name) extern "C" __declspec(dllexport) XSPROTO(name)

XS_EXTERNAL(boot_SmokePerl);
XS_EXTERNAL(boot_PerlSmokePerl)
{
    boot_SmokePerl(aTHX_ cv);
}
#endif

MODULE = SmokePerl PACKAGE = SmokePerl

PROTOTYPES: DISABLE

void*
getCppPointer(sv)
        SV* sv
    PPCODE:
        SmokePerl::Object* object = SmokePerl::Object::fromSV(sv);
        if (object == nullptr)
            XSRETURN_UNDEF;
        ST(0) = sv_2mortal(newSVnv((long long)object->value));
        XSRETURN(1);

SV*
getInstance(ptr)
        void* ptr
    PPCODE:
        SmokePerl::Object* object = SmokePerl::ObjectMap::instance().get(ptr);
        if (object == nullptr)
            XSRETURN_UNDEF;
        ST(0) = sv_2mortal(newSVsv(object->sv));
        XSRETURN(1);
