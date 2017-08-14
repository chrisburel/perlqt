xsubpp(qthelp.xs ${CMAKE_CURRENT_BINARY_DIR}/qthelp.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtHelp)
else()
    set(libraryName QtHelp)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqthelp5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qthelp.cpp
)

target_link_libraries(perlqthelp5
    Qt5::Help
    ${PERL_LIBRARY}
    ${SMOKE_QTHELP_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqthelp5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqthelp5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5helppm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtHelp.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtHelp.pm
)
install(FILES QtHelp.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
