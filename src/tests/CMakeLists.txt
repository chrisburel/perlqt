add_library(smoketestlib SHARED smoketestlib.cpp)

target_compile_features(smoketestlib PUBLIC
    cxx_nullptr
)

add_subdirectory(smoke)
add_subdirectory(module)
add_subdirectory(t)
