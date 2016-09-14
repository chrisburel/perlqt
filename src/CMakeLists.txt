include_directories(
    ${PERL_INCLUDE_PATH}
)

add_library(smokeperl SHARED
    handlers.cpp
    marshall.cpp
    methodcall.cpp
    methodresolution.cpp
    smokebinding.cpp
    smokemanager.cpp
    smokeobject.cpp
    xsfunctions.cpp
)

target_compile_features(smokeperl PUBLIC
    cxx_auto_type
    cxx_deleted_functions
    cxx_nullptr
)

target_link_libraries(smokeperl
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    ${PERL_LIBS}
    Qt5::Core
)

if(BUILD_TESTS)
    add_subdirectory(tests)
endif()
