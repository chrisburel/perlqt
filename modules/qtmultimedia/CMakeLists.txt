xsubpp(qtmultimedia.xs ${CMAKE_CURRENT_BINARY_DIR}/qtmultimedia.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtMultimedia)
else()
    set(libraryName QtMultimedia)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtmultimedia5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtmultimedia.cpp
)

target_link_libraries(perlqtmultimedia5
    Qt5::Core
    Qt5::Gui
    Qt5::Multimedia
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    ${SMOKE_QTCORE_LIBRARY}
    ${SMOKE_QTGUI_LIBRARY}
    ${SMOKE_QTMULTIMEDIA_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtmultimedia5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtmultimedia5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5multimediapm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtMultimedia.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtMultimedia.pm
)
install(FILES QtMultimedia.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
