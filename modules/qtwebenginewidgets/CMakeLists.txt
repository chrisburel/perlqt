xsubpp(qtwebenginewidgets.xs ${CMAKE_CURRENT_BINARY_DIR}/qtwebenginewidgets.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtWebEngineWidgets)
else()
    set(libraryName QtWebEngineWidgets)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtwebenginewidgets5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtwebenginewidgets.cpp
)

target_link_libraries(perlqtwebenginewidgets5
    Qt5::WebEngineWidgets
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    ${SMOKE_QTWEBENGINEWIDGETS_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtwebenginewidgets5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtwebenginewidgets5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5webenginewidgetspm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtWebEngineWidgets.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtWebEngineWidgets.pm
)
install(FILES QtWebEngineWidgets.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
