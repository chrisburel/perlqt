xsubpp(qtdbus.xs ${CMAKE_CURRENT_BINARY_DIR}/qtdbus.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtDBus)
else()
    set(libraryName QtDBus)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtdbus5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtdbus.cpp
)

target_link_libraries(perlqtdbus5
    ${PERL_LIBRARY}
    ${SMOKE_QTDBUS_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtdbus5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtdbus5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5dbuspm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtDBus.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtDBus.pm
)
install(FILES QtDBus.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
