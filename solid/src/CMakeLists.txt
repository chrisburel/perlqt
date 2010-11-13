include_directories(
    ${CMAKE_SOURCE_DIR}/smoke
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on Solid.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/Solid.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} Solid.xs ${CMAKE_CURRENT_BINARY_DIR}/Solid.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/Solid.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build Solid.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/Solid.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(solid_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/Solid.c
    solidhandlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/Solid)
add_library(perl_solid MODULE ${solid_LIBRARY_SRC})

target_link_libraries(perl_solid
    smokesolid
    perlqtcore4)

set_target_properties(perl_solid PROPERTIES OUTPUT_NAME "Solid")
set_target_properties(perl_solid PROPERTIES PREFIX "")

install(TARGETS perl_solid DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/Solid/)