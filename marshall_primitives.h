#ifndef MARSHALL_PRIMITIVES_H
#define MARSHALL_PRIMITIVES_H

template <>
unsigned int perl_to_primitive<unsigned int>(SV* sv) {
    return SvIV(sv);
}

template <>
SV* primitive_to_perl<unsigned int>(unsigned int sv) {
    return newSViv(sv);
}

template <>
double perl_to_primitive<double>(SV* sv) {
    return SvNV(sv);
}

template <>
SV* primitive_to_perl<double>(double sv) {
    return newSVnv(sv);
}

#endif //MARSHALL_PRIMITIVE5)S_H
