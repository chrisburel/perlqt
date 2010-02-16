#ifndef MARSHALL_PRIMITIVES_H
#define MARSHALL_PRIMITIVES_H

template <>
bool perl_to_primitive<bool>(SV* sv) {
    if ( !SvOK(sv) )
        return false;
    return SvTRUE(sv) ? true : false;
}
template <>
SV* primitive_to_perl<bool>(bool sv) {
    return boolSV(sv);
}

//-----------------------------------------------------------------------------
template<>
int perl_to_primitive<int>(SV* sv) {
    if ( !SvOK(sv) )
        return 0;
    if ( SvROK(sv) )
        return SvIV( SvRV(sv) );
    return SvIV(sv);
}

template<>
SV* primitive_to_perl<int>(int sv) {
    return newSViv(sv);
}

//-----------------------------------------------------------------------------
template <>
unsigned int perl_to_primitive<unsigned int>(SV* sv) {
    UNTESTED_HANDLER("perl_to_primitive<unsigned int>");
    if ( !SvOK(sv) )
        return 0;
    return SvUV(sv);
}

template <>
SV* primitive_to_perl<unsigned int>(unsigned int sv) {
    UNTESTED_HANDLER("primitive_to_perl<unsigned int>");
    return newSVuv(sv);
}

//-----------------------------------------------------------------------------
template <>
double perl_to_primitive<double>(SV* sv) {
    if ( !SvOK(sv) )
        return 0;
    return SvNV(sv);
}

template <>
SV* primitive_to_perl<double>(double sv) {
    return newSVnv(sv);
}

//-----------------------------------------------------------------------------
template<>
char* perl_to_primitive<char*>( SV* sv ) {
    if( !SvOK(sv) )
        return 0;
    return SvPV_nolen(sv);
}

#endif //MARSHALL_PRIMITIVES_H
