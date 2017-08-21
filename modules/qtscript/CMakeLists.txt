xsubpp(qtscript.xs ${CMAKE_CURRENT_BINARY_DIR}/qtscript.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtScript)
else()
    set(libraryName QtScript)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtscript5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtscript.cpp
)

target_link_libraries(perlqtscript5
    Qt5::Script
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    ${SMOKE_QTSCRIPT_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtscript5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtscript5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5scriptpm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtScript.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtScript.pm
)
install(FILES QtScript.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
