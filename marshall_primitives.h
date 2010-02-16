#ifndef MARSHALL_PRIMITIVES_H
#define MARSHALL_PRIMITIVES_H

//-----------------------------------------------------------------------------
template <>
bool perl_to_primitive<bool>(SV* sv) {
    return SvTRUE(sv) ? true : false;
}
template <>
SV* primitive_to_perl<bool>(bool sv) {
    return boolSV(sv);
}

//-----------------------------------------------------------------------------
template <>
int perl_to_primitive<int>(SV* sv) {
    return SvIV(sv);
}
template <>
SV* primitive_to_perl<int>(int sv) {
    return newSViv(sv);
}

//-----------------------------------------------------------------------------
template <>
unsigned int perl_to_primitive<unsigned int>(SV* sv) {
    return SvUV(sv);
}
template <>
SV* primitive_to_perl<unsigned int>(unsigned int sv) {
    return newSVuv(sv);
}

//-----------------------------------------------------------------------------
template <>
double perl_to_primitive<double>(SV* sv) {
    return SvNV(sv);
}
template <>
SV* primitive_to_perl<double>(double sv) {
    return newSVnv(sv);
}

#endif //MARSHALL_PRIMITIVE5)S_H
