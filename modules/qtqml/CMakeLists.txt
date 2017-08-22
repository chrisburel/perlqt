xsubpp(qtqml.xs ${CMAKE_CURRENT_BINARY_DIR}/qtqml.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtQml)
else()
    set(libraryName QtQml)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtqml5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtqml.cpp
)

target_link_libraries(perlqtqml5
    Qt5::Qml
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    ${SMOKE_QTQML_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtqml5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtqml5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5qmlpm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtQml.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtQml.pm
)
install(FILES QtQml.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
