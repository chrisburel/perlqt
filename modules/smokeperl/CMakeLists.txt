xsubpp(smokeperl.xs ${CMAKE_CURRENT_BINARY_DIR}/smokeperl.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

set(CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlSmokePerl)
else()
    set(libraryName SmokePerl)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/${libraryName})

add_library(perlsmokeperl SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/smokeperl.cpp
)

target_link_libraries(perlsmokeperl
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlsmokeperl PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/${libraryName}/
)

install(
    TARGETS perlsmokeperl
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/${libraryName}/
)

add_custom_target(
    perlsmokeperlpm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/SmokePerl.pm ${CMAKE_BINARY_DIR}/blib/lib/SmokePerl.pm
)

install(FILES SmokePerl.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR})
