xsubpp(qtprintsupport.xs ${CMAKE_CURRENT_BINARY_DIR}/qtprintsupport.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtPrintSupport)
else()
    set(libraryName QtPrintSupport)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtprintsupport5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtprintsupport.cpp
)

target_link_libraries(perlqtprintsupport5
    Qt5::PrintSupport
    ${PERL_LIBRARY}
    ${SMOKE_QTPRINTSUPPORT_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtprintsupport5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtprintsupport5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5printsupportpm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtPrintSupport.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtPrintSupport.pm
)
install(FILES QtPrintSupport.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
