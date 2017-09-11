#include <iostream>
#include "handlers.h"
#include "smokeobject.h"
#include "smokemanager.h"
#include "smokebinding.h"

namespace SmokePerl {

void marshall_basetype(Marshall* m) {
    switch(m->type().element()) {
        case Smoke::t_bool:
            marshall_PrimitiveRef<bool>(m);
        break;

        case Smoke::t_char:
            marshall_PrimitiveRef<signed char>(m);
        break;

        case Smoke::t_uchar:
            marshall_PrimitiveRef<unsigned char>(m);
        break;

        case Smoke::t_double:
            marshall_PrimitiveRef<double>(m);
        break;

        case Smoke::t_float:
            marshall_PrimitiveRef<float>(m);
        break;

        case Smoke::t_int:
            marshall_PrimitiveRef<int>(m);
        break;

        case Smoke::t_long:
            marshall_PrimitiveRef<long>(m);
        break;

        case Smoke::t_short:
            marshall_PrimitiveRef<signed short>(m);
        break;

        case Smoke::t_ushort:
            marshall_PrimitiveRef<unsigned short>(m);
        break;

        case Smoke::t_enum:
            switch(m->action()) {
                case Marshall::FromSV:
                {
                    if (SvROK(m->var())) {
                        m->item().s_enum = (long)SvIV(SvRV(m->var()));
                    }
                    else {
                        m->item().s_enum = (long)SvIV(m->var());
                    }
                }
                break;
                case Marshall::ToSV:
                {
                    SV* rv = newRV_noinc(newSViv((IV)m->item().s_enum));
                    std::string package = SmokePerl::SmokeManager::instance().getPackageForSmoke(m->type().smoke());
                    sv_bless(rv, gv_stashpv((package + "::" + m->type().name()).c_str(), TRUE));
                    SvSetMagicSV(m->var(), rv);
                }
                break;
            }
        break;

        case Smoke::t_class: {
            switch(m->action()) {
                case Marshall::FromSV:
                {
                    Object* obj = SmokePerl::Object::fromSV(m->var());
                    if (obj == nullptr) {
                        m->item().s_class = nullptr;
                        break;
                    }

                    m->item().s_voidp = obj->cast({m->smoke(), m->type().classId()});
                }
                break;
                case Marshall::ToSV:
                {
                    // Get return value
                    void* cxxptr = m->item().s_voidp;

                    if (cxxptr == nullptr) {
                        SvSetMagicSV(m->var(), &PL_sv_undef);
                        return;
                    }

                    Object* obj = SmokePerl::ObjectMap::instance().get(cxxptr);

                    if (obj != nullptr) {
                        SvSetMagicSV(m->var(), obj->sv);
                        return;
                    }

                    obj = new Object(
                        cxxptr,
                        Smoke::findClass(m->smoke()->classes[m->type().classId()].className),
                        ((m->type().flags() & Smoke::tf_ref) == Smoke::tf_stack) ? Object::ScriptOwnership : Object::CppOwnership
                    );

                    SV* sv = obj->wrap();
                    ObjectMap::instance().insert(obj, obj->classId);

                    SmokePerl::SmokePerlBinding* binding = SmokePerl::SmokeManager::instance().getBindingForSmoke(obj->classId.smoke);
                    const char* pkg = binding->className(obj->classId.index);
                    sv_bless(sv, gv_stashpv(pkg, TRUE));

                    SvSetMagicSV(m->var(), sv);
                }
                break;
            }
        }
        break;

        default:
            return marshall_unknown(m);
            break;
    }
}

void marshall_unknown(Marshall* m) {
    m->unsupported();
}

void marshall_void(Marshall* m) {}

template <class T> T* selectSmokeStackField(Marshall *m) { return (T*) m->item().s_voidp; }

template<> bool* selectSmokeStackField<bool>(Marshall *m) { return &m->item().s_bool; }
template<> signed char* selectSmokeStackField<signed char>(Marshall *m) { return &m->item().s_char; }
template<> unsigned char* selectSmokeStackField<unsigned char>(Marshall *m) { return &m->item().s_uchar; }
template<> short* selectSmokeStackField<short>(Marshall *m) { return &m->item().s_short; }
template<> unsigned short* selectSmokeStackField<unsigned short>(Marshall *m) { return &m->item().s_ushort; }
template<> int* selectSmokeStackField<int>(Marshall *m) { return &m->item().s_int; }
template<> unsigned int* selectSmokeStackField<unsigned int>(Marshall *m) { return &m->item().s_uint; }
template<> long* selectSmokeStackField<long>(Marshall *m) { 	return &m->item().s_long; }
template<> unsigned long* selectSmokeStackField<unsigned long>(Marshall *m) { return &m->item().s_ulong; }
template<> float* selectSmokeStackField<float>(Marshall *m) { return &m->item().s_float; }
template<> double* selectSmokeStackField<double>(Marshall *m) { return &m->item().s_double; }

template <class T> T perlToPrimitive(SV*);

template<>
bool perlToPrimitive<bool>(SV* sv) {
    return SvTRUE(sv);
}

template<>
signed char perlToPrimitive<signed char>(SV* sv) {
    if (!SvOK(sv))
        return 0;
    if (SvIOK(sv))
        return (char)SvIV(sv);
    char* str = SvPV_nolen(sv);
    return *str;
}

template<>
unsigned char perlToPrimitive<unsigned char>(SV* sv) {
    if (!SvOK(sv))
        return 0;
    if (SvIOK(sv))
        return (unsigned char)SvUV(sv);
    char* str = SvPV_nolen(sv);
    return *(unsigned char*)str;
}

template<>
double perlToPrimitive<double>(SV* sv) {
    if (!SvOK(sv))
        return 0;
    return SvNV(sv);
}

template<>
float perlToPrimitive<float>(SV* sv) {
    if (!SvOK(sv))
        return 0;
    return SvNV(sv);
}

template<>
int perlToPrimitive<int>(SV* sv) {
    if (!SvOK(sv))
        return 0;
    if (SvROK(sv)) // Because enums can be used as ints
        return SvIV(SvRV(sv));
    return SvIV(sv);
}

template<>
long perlToPrimitive<long>(SV* sv) {
    if (!SvOK(sv))
        return 0;
    return (long)SvIV(sv);
}

template<>
signed short perlToPrimitive<signed short>(SV* sv) {
    if (!SvOK(sv))
        return 0;
    if (SvROK(sv))
        sv = SvRV(sv);
    return (signed short)SvIV(sv);
}

template<>
unsigned short perlToPrimitive<unsigned short>(SV* sv) {
    if (!SvOK(sv))
        return 0;
    if (SvROK(sv))
        sv = SvRV(sv);
    return (signed short)SvUV(sv);
}

template<>
char* perlToPrimitive<char*>(SV* sv) {
    if (!SvOK(sv))
        return 0;
    if (SvROK(sv))
        sv = SvRV(sv);
    char* str = SvPV_nolen(sv);
    return str;
}

template <class T> SV* primitiveToPerl(T);

template<>
SV* primitiveToPerl<bool>(bool boolVal) {
    return boolSV(boolVal);
}

template<>
SV* primitiveToPerl<signed char>(signed char charVal) {
    SV* sv = newSViv(charVal);
    return sv;
}

template<>
SV* primitiveToPerl<unsigned char>(unsigned char charVal) {
    return newSVuv(charVal);
}

template<>
SV* primitiveToPerl<double>(double doubleVal) {
    return newSVnv(doubleVal);
}

template<>
SV* primitiveToPerl<float>(float floatVal) {
    return newSVnv(floatVal);
}

template<>
SV* primitiveToPerl<int>(int intVal) {
    return newSViv(intVal);
}

template<>
SV* primitiveToPerl<long>(long longVal) {
    return newSViv(longVal);
}

template<>
SV* primitiveToPerl<signed short>(signed short shortVal) {
    return newSViv(shortVal);
}

template<>
SV* primitiveToPerl<unsigned short>(unsigned short shortVal) {
    return newSVuv(shortVal);
}

template <class T>
static void marshallFromPerl(Marshall* m) {
    (*selectSmokeStackField<T>(m)) = perlToPrimitive<T>(m->var());
}

template<>
void marshallFromPerl<char*>(Marshall* m) {
    SV* sv = m->var();
    char* buf = nullptr;
    if (SvFLAGS(sv) & SVs_TEMP) {
        STRLEN len = SvLEN(sv);
        buf = new char[len];
        strncpy(buf, SvPV_nolen(sv), len);
    }
    else {
        buf = SvPV_nolen(sv);
    }
    m->item().s_voidp = buf;
    m->next();
    if (!m->type().isConst() && !SvREADONLY(sv)) {
        sv_setpv(sv, buf);
    }
    if (m->cleanup() && SvFLAGS(sv) & SVs_TEMP) {
        delete[] buf;
    }
}

template<>
void marshallFromPerl<int*>(Marshall* m) {
    SV *sv = m->var();
    if ( !SvOK(sv) ) {
        sv_setiv( sv, 0 );
    }
    if ( SvROK(sv) ) {
        sv = SvRV(sv);
    }

    if ( !SvIOK(sv) ) {
        sv_setiv( sv, 0 );
    }

    int *i = new int(SvIV(sv));
    m->item().s_voidp = i;
    m->next();

    if(m->cleanup() && m->type().isConst()) {
        delete i;
    } else {
        sv_setiv(sv, *i);
    }
}

template void marshallFromPerl<int*>(Marshall* m);

template <class T>
static void marshallToPerl(Marshall* m) {
    SvSetMagicSV(m->var(), primitiveToPerl<T>(*selectSmokeStackField<T>(m)));
}

template <>
void marshallToPerl<char*>(Marshall* m) {
    char* str = (char*)m->item().s_voidp;
    SV* sv = newSV(0);
    sv_setpv(sv, str);

    if (m->cleanup())
        delete[] str;

    SvSetMagicSV(m->var(), sv);
}

template <>
void marshallToPerl<int*>(Marshall* m) {
    int* num = (int*)m->item().s_voidp;
    SV* sv = newSV(0);
    sv_setiv(sv, *num);

    if (m->cleanup())
        delete num;

    SvSetMagicSV(m->var(), sv);
}

template <class T>
void marshall_PrimitiveRef(Marshall* m) {
    switch(m->action()) {
        case Marshall::FromSV: {
            marshallFromPerl<T>(m);
            break;
        }
        case Marshall::ToSV: {
            marshallToPerl<T>(m);
            break;
        }
        default:
            m->unsupported();
            break;
    }
}

template void marshall_PrimitiveRef<char*>(Marshall* m);
template void marshall_PrimitiveRef<int>(Marshall* m);
template void marshall_PrimitiveRef<int*>(Marshall* m);

void marshall_CharPArray(Marshall* m) {
    switch( m->action() ) {
        case Marshall::FromSV: {
            SV* arglistref = m->var();
            if ( !SvOK( arglistref ) && !SvROK( arglistref ) ) {
                m->item().s_voidp = 0;
                break;
            }

            AV* arglist = (AV*)SvRV( arglistref );

            int argc = av_len(arglist) + 1;
            char** argv = new char*[argc + 1];
            long i;
            for (i = 0; i < argc; ++i) {
                SV** item = av_fetch(arglist, i, 0);
                if( item ) {
                    STRLEN len = 0;
                    char* s = SvPV( *item, len );
                    argv[i] = new char[len + 1];
                    strcpy( argv[i], s );
                }
            }
            argv[i] = 0;
            m->item().s_voidp = argv;
            m->next();

            // No cleanup, we don't know what's pointing to us
        }
        break;

        default:
            m->unsupported();
        break;
    }
}

void marshall_VoidPArray(Marshall* m) {
    // A void** type is an opaque type to Perl, but it is necessary to allow
    // XS functions that deal with this type to be passed through the
    // marshalling process.
    switch(m->action()) {
        case Marshall::FromSV:
            m->item().s_voidp = SmokePerl::Object::fromSV(m->var())->value;
        break;

        case Marshall::ToSV:
        {
            void* cxxptr = m->item().s_voidp;

            SmokePerl::Object* obj = new Object(
                cxxptr,
                Smoke::NullModuleIndex,
                Object::CppOwnership
            );

            SV* sv = obj->wrap();

            SvSetMagicSV(m->var(), sv);
        }
        break;

        default:
            m->unsupported();
        break;
    }
}

}
