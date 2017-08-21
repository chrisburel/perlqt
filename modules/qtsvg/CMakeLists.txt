xsubpp(qtsvg.xs ${CMAKE_CURRENT_BINARY_DIR}/qtsvg.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtSvg)
else()
    set(libraryName QtSvg)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtsvg5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtsvg.cpp
)

target_link_libraries(perlqtsvg5
    Qt5::Svg
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    ${SMOKE_QTSVG_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtsvg5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtsvg5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5svgpm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtSvg.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtSvg.pm
)
install(FILES QtSvg.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
