xsubpp(qtmultimediawidgets.xs ${CMAKE_CURRENT_BINARY_DIR}/qtmultimediawidgets.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtMultimediaWidgets)
else()
    set(libraryName QtMultimediaWidgets)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtmultimediawidgets5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtmultimediawidgets.cpp
)

target_link_libraries(perlqtmultimediawidgets5
    Qt5::MultimediaWidgets
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    ${SMOKE_QTMULTIMEDIAWIDGETS_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtmultimediawidgets5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtmultimediawidgets5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5multimediawidgetspm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtMultimediaWidgets.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtMultimediaWidgets.pm
)
install(FILES QtMultimediaWidgets.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
