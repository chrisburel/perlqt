xsubpp(qtuitools.xs ${CMAKE_CURRENT_BINARY_DIR}/qtuitools.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtUiTools)
else()
    set(libraryName QtUiTools)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtuitools5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtuitools.cpp
)

target_link_libraries(perlqtuitools5
    Qt5::UiTools
    ${PERL_LIBRARY}
    ${SMOKE_QTUITOOLS_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtuitools5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtuitools5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5uitoolspm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtUiTools.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtUiTools.pm
)
install(FILES QtUiTools.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
