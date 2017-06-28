xsubpp(smoketest.xs ${CMAKE_CURRENT_BINARY_DIR}/smoketest.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/../smoke
    ${PERL_INCLUDE_PATH}
)
add_definitions(${PERL_CXX_FLAGS})

set(libraryName PerlSmokeTest)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/${libraryName})

add_library(perlsmoketest SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/smoketest.cpp
)

target_link_libraries(perlsmoketest
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    smokeperl
    smokesmoketestlib
)

set_target_properties(perlsmoketest PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
)

add_custom_target(
    perlsmoketestpm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/PerlSmokeTest.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlSmokeTest.pm
)
