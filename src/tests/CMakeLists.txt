add_library(smoketestlib SHARED smoketestlib.cpp)

target_compile_features(smoketestlib PUBLIC
    cxx_nullptr
)

install(
    TARGETS smoketestlib
    DESTINATION ${CMAKE_INSTALL_PREFIX}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
)

add_subdirectory(smoke)
add_subdirectory(module)
add_subdirectory(t)
