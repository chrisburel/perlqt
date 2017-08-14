xsubpp(qtsql.xs ${CMAKE_CURRENT_BINARY_DIR}/qtsql.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtSql)
else()
    set(libraryName QtSql)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtsql5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtsql.cpp
)

target_link_libraries(perlqtsql5
    Qt5::Sql
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    ${SMOKE_QTSQL_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtsql5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtsql5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5sqlpm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtSql.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtSql.pm
)
install(FILES QtSql.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
