xsubpp(qtxmlpatterns.xs ${CMAKE_CURRENT_BINARY_DIR}/qtxmlpatterns.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtXmlPatterns)
else()
    set(libraryName QtXmlPatterns)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtxmlpatterns5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtxmlpatterns.cpp
)

target_link_libraries(perlqtxmlpatterns5
    Qt5::Core
    Qt5::Gui
    Qt5::XmlPatterns
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    ${SMOKE_QTCORE_LIBRARY}
    ${SMOKE_QTGUI_LIBRARY}
    ${SMOKE_QTXMLPATTERNS_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtxmlpatterns5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtxmlpatterns5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5xmlpatternspm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtXmlPatterns.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtXmlPatterns.pm
)
install(FILES QtXmlPatterns.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
