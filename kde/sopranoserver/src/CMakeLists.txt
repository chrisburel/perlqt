include_directories(
    ${CMAKE_SOURCE_DIR}/generator
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on SopranoServer.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/SopranoServer.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${PERLQT_SHARE_DIR}/doxsubpp.pl ${PERL_EXECUTABLE} SopranoServer.xs ${CMAKE_CURRENT_BINARY_DIR}/SopranoServer.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/SopranoServer.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build SopranoServer.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/SopranoServer.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(sopranoserver_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/SopranoServer.c
    sopranoserverhandlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/SopranoServer)
add_library(perl_sopranoserver MODULE ${sopranoserver_LIBRARY_SRC})

target_link_libraries(perl_sopranoserver
    ${SMOKE_SOPRANOSERVER_LIBRARY}
    ${PERLQTCORE4_LIBRARY})

set_target_properties(perl_sopranoserver PROPERTIES OUTPUT_NAME "SopranoServer")
set_target_properties(perl_sopranoserver PROPERTIES PREFIX "")

install(TARGETS perl_sopranoserver DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/SopranoServer/)