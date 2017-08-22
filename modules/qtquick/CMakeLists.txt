xsubpp(qtquick.xs ${CMAKE_CURRENT_BINARY_DIR}/qtquick.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtQuick)
else()
    set(libraryName QtQuick)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtquick5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtquick.cpp
)

target_link_libraries(perlqtquick5
    Qt5::Quick
    ${PERL_LIBRARY}
    ${SMOKE_QTQUICK_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtquick5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtquick5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5quickpm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtQuick.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtQuick.pm
)
install(FILES QtQuick.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
