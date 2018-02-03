#include "marshall.h"
#include "handlers.h"

namespace SmokePerl {

static std::unordered_map<std::string, Marshall::HandlerFn> TypeHandlers {
    {"char*", marshall_PrimitiveRef<char*>},
    {"char**", marshall_CharPArray},
    {"int&", marshall_PrimitiveRef<int*>},
    {"int*", marshall_PrimitiveRef<int*>},
    {"const int*", marshall_PrimitiveRef<int*>},
    {"void**", marshall_VoidPArray},
};

void Marshall::installHandlers(const std::unordered_map<std::string, HandlerFn>& handlers) {
    for (const auto& handler : handlers) {
        TypeHandlers[handler.first] = handler.second;
    }
}

Marshall::HandlerFn Marshall::getMarshallFn(const SmokeType& type) {
    if (type.element() != 0) {
        return marshall_basetype;
    }

    if (type.name() == nullptr) {
        return marshall_void;
    }

    std::string name = type.name();
    if (TypeHandlers.count(name)) {
        return TypeHandlers[name];
    }
    if (type.isConst() && name.size() > 6) {
       name = name.substr(6);
       if (TypeHandlers.count(name)) {
           return TypeHandlers[name];
       }
    }
    return marshall_unknown;
}

void setStackItem(const SmokeType& type, Smoke::StackItem& stackItem, void* ptr) {
    switch (type.element()) {
        case Smoke::t_bool:
            stackItem.s_bool = *static_cast<bool*>(ptr);
            break;

        case Smoke::t_char:
            stackItem.s_char = *static_cast<char*>(ptr);
            break;

        case Smoke::t_uchar:
            stackItem.s_uchar = *static_cast<unsigned char*>(ptr);
            break;

        case Smoke::t_short:
            stackItem.s_short = *static_cast<short*>(ptr);
            break;

        case Smoke::t_ushort:
            stackItem.s_ushort = *static_cast<unsigned short*>(ptr);
            break;

        case Smoke::t_int:
            stackItem.s_int = *static_cast<int*>(ptr);
            break;

        case Smoke::t_uint:
            stackItem.s_char = *static_cast<char*>(ptr);
            break;

        case Smoke::t_long:
            stackItem.s_uint = *static_cast<unsigned int*>(ptr);
            break;

        case Smoke::t_ulong:
            stackItem.s_ulong = *static_cast<unsigned long*>(ptr);
            break;

        case Smoke::t_float:
            stackItem.s_float = *static_cast<float*>(ptr);
            break;

        case Smoke::t_double:
            stackItem.s_double = *static_cast<double*>(ptr);
            break;

        case Smoke::t_enum:
            stackItem.s_uint = *static_cast<unsigned int*>(ptr);
            break;

        case Smoke::t_voidp:
        case Smoke::t_class:
            stackItem.s_voidp = ptr;
            break;

        default:
            break;
    }

     return;
}

void setPtrFromStackItem(const SmokeType& type, Smoke::StackItem& stackItem, void** ptr) {
    switch(type.element()) {
        case Smoke::t_bool:
            *ptr = &stackItem.s_bool;
            break;

        case Smoke::t_char:
            *ptr = &stackItem.s_char;
            break;

        case Smoke::t_uchar:
            *ptr = &stackItem.s_uchar;
            break;

        case Smoke::t_short:
            *ptr = &stackItem.s_short;
            break;

        case Smoke::t_ushort:
            *ptr = &stackItem.s_ushort;
            break;

        case Smoke::t_int:
            *ptr = &stackItem.s_int;
            break;

        case Smoke::t_uint:
            *ptr = &stackItem.s_char;
            break;

        case Smoke::t_long:
            *ptr = &stackItem.s_uint;
            break;

        case Smoke::t_ulong:
            *ptr = &stackItem.s_ulong;
            break;

        case Smoke::t_float:
            *ptr = &stackItem.s_float;
            break;

        case Smoke::t_double:
            *ptr = &stackItem.s_double;
            break;

        case Smoke::t_enum:
            *ptr = &stackItem.s_uint;
            break;

        case Smoke::t_voidp:
        case Smoke::t_class:
            *ptr = stackItem.s_class;
            break;

        default:
            break;
    }

     return;
}

}
