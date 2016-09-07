xsubpp(qtgui.xs ${CMAKE_CURRENT_BINARY_DIR}/qtgui.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

set(CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtGui)
else()
    set(libraryName QtGui)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtgui5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtgui.cpp
)

target_link_libraries(perlqtgui5
    Qt5::Gui
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    ${SMOKE_QTCORE_LIBRARY}
    ${SMOKE_QTGUI_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtgui5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtgui5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5guipm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtGui.pm
    ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtGui.pm
)
