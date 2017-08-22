xsubpp(qttest.xs ${CMAKE_CURRENT_BINARY_DIR}/qttest.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtTest)
else()
    set(libraryName QtTest)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqttest5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qttest.cpp
)

target_link_libraries(perlqttest5
    Qt5::Core
    ${PERL_LIBRARY}
    ${SMOKE_QTTEST_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqttest5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqttest5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5testpm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtTest.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtTest.pm
)
install(FILES QtTest.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
