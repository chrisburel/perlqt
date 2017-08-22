xsubpp(qtpositioning.xs ${CMAKE_CURRENT_BINARY_DIR}/qtpositioning.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtPositioning)
else()
    set(libraryName QtPositioning)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtpositioning5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtpositioning.cpp
)

target_link_libraries(perlqtpositioning5
    Qt5::Positioning
    ${PERL_LIBRARY}
    ${SMOKE_QTPOSITIONING_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtpositioning5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtpositioning5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5positioningpm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtPositioning.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtPositioning.pm
)
install(FILES QtPositioning.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
