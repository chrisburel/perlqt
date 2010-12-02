include_directories(
    ${CMAKE_SOURCE_DIR}/generator
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on KUtils.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/KUtils.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} KUtils.xs ${CMAKE_CURRENT_BINARY_DIR}/KUtils.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/KUtils.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build KUtils.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/KUtils.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(kutils_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/KUtils.c
    kutilshandlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/KUtils)
add_library(perl_kutils MODULE ${kutils_LIBRARY_SRC})

target_link_libraries(perl_kutils
    smokekutils
    perlqtcore4)

set_target_properties(perl_kutils PROPERTIES OUTPUT_NAME "KUtils")
set_target_properties(perl_kutils PROPERTIES PREFIX "")

install(TARGETS perl_kutils DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/KUtils/)