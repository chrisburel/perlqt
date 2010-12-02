include_directories(
    ${CMAKE_SOURCE_DIR}/generator
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on KNewStuff3.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/KNewStuff3.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} KNewStuff3.xs ${CMAKE_CURRENT_BINARY_DIR}/KNewStuff3.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/KNewStuff3.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build KNewStuff3.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/KNewStuff3.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(knewstuff3_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/KNewStuff3.c
    knewstuff3handlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/KNewStuff3)
add_library(perl_knewstuff3 MODULE ${knewstuff3_LIBRARY_SRC})

target_link_libraries(perl_knewstuff3
    smokeknewstuff3
    perlqtcore4)

set_target_properties(perl_knewstuff3 PROPERTIES OUTPUT_NAME "KNewStuff3")
set_target_properties(perl_knewstuff3 PROPERTIES PREFIX "")

install(TARGETS perl_knewstuff3 DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/KNewStuff3/)