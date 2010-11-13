include_directories(
    ${CMAKE_SOURCE_DIR}/smoke
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on SopranoCerver.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/SopranoCerver.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} SopranoCerver.xs ${CMAKE_CURRENT_BINARY_DIR}/SopranoCerver.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/SopranoCerver.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build SopranoCerver.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/SopranoCerver.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(sopranoserver_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/SopranoCerver.c
    sopranoserverhandlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/SopranoCerver)
add_library(perl_sopranoserver MODULE ${sopranoserver_LIBRARY_SRC})

target_link_libraries(perl_sopranoserver
    smokesopranoserver
    perlqtcore4)

set_target_properties(perl_sopranoserver PROPERTIES OUTPUT_NAME "SopranoCerver")
set_target_properties(perl_sopranoserver PROPERTIES PREFIX "")

install(TARGETS perl_sopranoserver DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/SopranoCerver/)