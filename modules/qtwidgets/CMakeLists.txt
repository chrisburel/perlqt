xsubpp(qtwidgets.xs ${CMAKE_CURRENT_BINARY_DIR}/qtwidgets.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtWidgets)
else()
    set(libraryName QtWidgets)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtwidgets5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtwidgets.cpp
)

target_link_libraries(perlqtwidgets5
    Qt5::Core
    Qt5::Gui
    Qt5::Widgets
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    ${SMOKE_QTCORE_LIBRARY}
    ${SMOKE_QTGUI_LIBRARY}
    ${SMOKE_QTWIDGETS_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtwidgets5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtwidgets5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5widgetspm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtWidgets.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtWidgets.pm
)
install(FILES QtWidgets.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
