include_directories(
    ${CMAKE_SOURCE_DIR}/generator
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on Soprano.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/Soprano.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${PERLQT_SHARE_DIR}/doxsubpp.pl ${PERL_EXECUTABLE} Soprano.xs ${CMAKE_CURRENT_BINARY_DIR}/Soprano.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/Soprano.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build Soprano.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/Soprano.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(soprano_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/Soprano.c
    sopranohandlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/Soprano)
add_library(perl_soprano MODULE ${soprano_LIBRARY_SRC})

target_link_libraries(perl_soprano
    ${SMOKE_SOPRANO_LIBRARY}
    ${PERLQTCORE4_LIBRARY})

set_target_properties(perl_soprano PROPERTIES OUTPUT_NAME "Soprano")
set_target_properties(perl_soprano PROPERTIES PREFIX "")

install(TARGETS perl_soprano DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/Soprano/)