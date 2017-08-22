xsubpp(qtwebchannel.xs ${CMAKE_CURRENT_BINARY_DIR}/qtwebchannel.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtWebChannel)
else()
    set(libraryName QtWebChannel)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtwebchannel5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtwebchannel.cpp
)

target_link_libraries(perlqtwebchannel5
    Qt5::WebChannel
    ${PERL_LIBRARY}
    ${SMOKE_QTWEBCHANNEL_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtwebchannel5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtwebchannel5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5webchannelpm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtWebChannel.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtWebChannel.pm
)
install(FILES QtWebChannel.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
