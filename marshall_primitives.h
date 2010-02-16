#ifndef MARSHALL_PRIMITIVES_H
#define MARSHALL_PRIMITIVES_H

template <>
unsigned int perl_to_primitive<unsigned int>(SV sv) {
    return SvIV(&sv);
}

template <>
SV primitive_to_perl<unsigned int>(unsigned int sv) {
    return *newSViv(5);
}
#endif //MARSHALL_PRIMITIVES_H
