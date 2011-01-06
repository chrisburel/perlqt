include_directories(
    ${CMAKE_SOURCE_DIR}/generator
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${KDE4_INCLUDE_DIR}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on Plasma4.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/Plasma4.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${PERLQT_SHARE_DIR}/doxsubpp.pl ${PERL_EXECUTABLE} Plasma4.xs ${CMAKE_CURRENT_BINARY_DIR}/Plasma4.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/Plasma4.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build Plasma4.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/Plasma4.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(plasma4_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/Plasma4.c
    plasma4handlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/Plasma4)
add_library(perl_plasma4 MODULE ${plasma4_LIBRARY_SRC})

target_link_libraries(perl_plasma4
    ${SMOKE_PLASMA_LIBRARY}
    ${PERLQTCORE4_LIBRARY})

set_target_properties(perl_plasma4 PROPERTIES OUTPUT_NAME "Plasma4")
set_target_properties(perl_plasma4 PROPERTIES PREFIX "")

install(TARGETS perl_plasma4 DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/Plasma4/)
