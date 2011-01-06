include_directories(
    ${CMAKE_SOURCE_DIR}/generator
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on KNewStuff2.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/KNewStuff2.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${PERLQT_SHARE_DIR}/doxsubpp.pl ${PERL_EXECUTABLE} KNewStuff2.xs ${CMAKE_CURRENT_BINARY_DIR}/KNewStuff2.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/KNewStuff2.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build KNewStuff2.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/KNewStuff2.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(knewstuff2_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/KNewStuff2.c
    knewstuff2handlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/KNewStuff2)
add_library(perl_knewstuff2 MODULE ${knewstuff2_LIBRARY_SRC})

target_link_libraries(perl_knewstuff2
    ${SMOKE_KNEWSTUFF2_LIBRARY}
    ${PERLQTCORE4_LIBRARY})

set_target_properties(perl_knewstuff2 PROPERTIES OUTPUT_NAME "KNewStuff2")
set_target_properties(perl_knewstuff2 PROPERTIES PREFIX "")

install(TARGETS perl_knewstuff2 DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/KNewStuff2/)