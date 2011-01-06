include_directories(
    ${CMAKE_SOURCE_DIR}/generator
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on SopranoClient.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/SopranoClient.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${PERLQT_SHARE_DIR}/doxsubpp.pl ${PERL_EXECUTABLE} SopranoClient.xs ${CMAKE_CURRENT_BINARY_DIR}/SopranoClient.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/SopranoClient.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build SopranoClient.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/SopranoClient.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(sopranoclient_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/SopranoClient.c
    sopranoclienthandlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/SopranoClient)
add_library(perl_sopranoclient MODULE ${sopranoclient_LIBRARY_SRC})

target_link_libraries(perl_sopranoclient
    ${SMOKE_SOPRANOCLIENT_LIBRARY}
    ${PERLQTCORE4_LIBRARY})

set_target_properties(perl_sopranoclient PROPERTIES OUTPUT_NAME "SopranoClient")
set_target_properties(perl_sopranoclient PROPERTIES PREFIX "")

install(TARGETS perl_sopranoclient DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/SopranoClient/)