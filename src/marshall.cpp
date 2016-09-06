#include "marshall.h"
#include "handlers.h"

namespace SmokePerl {

static std::unordered_map<std::string, Marshall::HandlerFn> TypeHandlers {
    {"int&", marshall_PrimitiveRef<int*>},
    {"char**", marshall_CharPArray},
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

}
