xsubpp(qtxml.xs ${CMAKE_CURRENT_BINARY_DIR}/qtxml.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtXml)
else()
    set(libraryName QtXml)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtxml5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtxml.cpp
)

target_link_libraries(perlqtxml5
    Qt5::Xml
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    ${SMOKE_QTXML_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtxml5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtxml5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5xmlpm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtXml.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtXml.pm
)
install(FILES QtXml.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
