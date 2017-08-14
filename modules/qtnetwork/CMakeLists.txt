xsubpp(qtnetwork.xs ${CMAKE_CURRENT_BINARY_DIR}/qtnetwork.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtNetwork)
else()
    set(libraryName QtNetwork)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtnetwork5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtnetwork.cpp
)

target_link_libraries(perlqtnetwork5
    Qt5::Network
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    ${SMOKE_QTNETWORK_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtnetwork5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtnetwork5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5networkpm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtNetwork.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtNetwork.pm
)
install(FILES QtNetwork.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
