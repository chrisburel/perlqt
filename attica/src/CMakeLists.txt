include_directories(
    ${CMAKE_SOURCE_DIR}/generator
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on Attica.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/Attica.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} Attica.xs ${CMAKE_CURRENT_BINARY_DIR}/Attica.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/Attica.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build Attica.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/Attica.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(attica_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/Attica.c
    atticahandlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/Attica)
add_library(perl_attica MODULE ${attica_LIBRARY_SRC})

target_link_libraries(perl_attica
    smokeattica
    perlqtcore4)

set_target_properties(perl_attica PROPERTIES OUTPUT_NAME "Attica")
set_target_properties(perl_attica PROPERTIES PREFIX "")

install(TARGETS perl_attica DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/Attica/)