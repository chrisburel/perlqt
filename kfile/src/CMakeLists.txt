include_directories(
    ${CMAKE_SOURCE_DIR}/generator
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on KFile.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/KFile.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} KFile.xs ${CMAKE_CURRENT_BINARY_DIR}/KFile.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/KFile.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build KFile.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/KFile.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(kfile_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/KFile.c
    kfilehandlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/KFile)
add_library(perl_kfile MODULE ${kfile_LIBRARY_SRC})

target_link_libraries(perl_kfile
    smokekfile
    perlqtcore4)

set_target_properties(perl_kfile PROPERTIES OUTPUT_NAME "KFile")
set_target_properties(perl_kfile PROPERTIES PREFIX "")

install(TARGETS perl_kfile DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/KFile/)