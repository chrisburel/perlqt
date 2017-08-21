xsubpp(qtwebenginecore.xs ${CMAKE_CURRENT_BINARY_DIR}/qtwebenginecore.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtWebEngineCore)
else()
    set(libraryName QtWebEngineCore)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtwebenginecore5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtwebenginecore.cpp
)

target_link_libraries(perlqtwebenginecore5
    Qt5::WebEngineCore
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    ${SMOKE_QTWEBENGINECORE_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtwebenginecore5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtwebenginecore5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5webenginecorepm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtWebEngineCore.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtWebEngineCore.pm
)
install(FILES QtWebEngineCore.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
