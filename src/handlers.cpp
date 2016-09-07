#include <iostream>
#include "handlers.h"
#include "smokeobject.h"
#include "smokemanager.h"
#include "smokebinding.h"

namespace SmokePerl {

void marshall_basetype(Marshall* m) {
    switch(m->type().element()) {
        case Smoke::t_int:
            marshall_PrimitiveRef<int>(m);
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

                    SV* sv = SmokePerl::ObjectMap::instance().get(cxxptr);

                    if (sv != nullptr) {
                        SvSetMagicSV(m->var(), sv);
                        return;
                    }

                    Object* obj = new Object(
                        cxxptr,
                        Smoke::findClass(m->smoke()->classes[m->type().classId()].className),
                        Object::QtOwnership
                    );

                    sv = obj->wrap();

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
int perlToPrimitive<int>(SV* sv) {
    if (!SvOK(sv))
        return 0;
    if (SvROK(sv)) // Because enums can be used as ints
        return SvIV(SvRV(sv));
    return SvIV(sv);
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
SV* primitiveToPerl<int>(int intVal) {
    return newSViv(intVal);
}

template <class T>
static void marshallFromPerl(Marshall* m) {
    (*selectSmokeStackField<T>(m)) = perlToPrimitive<T>(m->var());
}

template<>
void marshallFromPerl<char*>(Marshall* m) {
    SV* sv = m->var();
    char* buf = perlToPrimitive<char*>(sv);
    m->item().s_voidp = buf;
    m->next();
    if (!m->type().isConst() && !SvREADONLY(sv)) {
        sv_setpv(sv, buf);
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
}
