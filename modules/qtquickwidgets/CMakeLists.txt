xsubpp(qtquickwidgets.xs ${CMAKE_CURRENT_BINARY_DIR}/qtquickwidgets.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtQuickWidgets)
else()
    set(libraryName QtQuickWidgets)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtquickwidgets5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtquickwidgets.cpp
)

target_link_libraries(perlqtquickwidgets5
    Qt5::QuickWidgets
    ${PERL_LIBRARY}
    ${SMOKE_QTQUICKWIDGETS_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtquickwidgets5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtquickwidgets5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5quickwidgetspm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtQuickWidgets.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtQuickWidgets.pm
)
install(FILES QtQuickWidgets.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
