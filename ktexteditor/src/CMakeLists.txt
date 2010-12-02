include_directories(
    ${CMAKE_SOURCE_DIR}/generator
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on KTextEditor.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/KTextEditor.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} KTextEditor.xs ${CMAKE_CURRENT_BINARY_DIR}/KTextEditor.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/KTextEditor.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build KTextEditor.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/KTextEditor.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(ktexteditor_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/KTextEditor.c
    ktexteditorhandlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/KTextEditor)
add_library(perl_ktexteditor MODULE ${ktexteditor_LIBRARY_SRC})

target_link_libraries(perl_ktexteditor
    smokektexteditor
    perlqtcore4)

set_target_properties(perl_ktexteditor PROPERTIES OUTPUT_NAME "KTextEditor")
set_target_properties(perl_ktexteditor PROPERTIES PREFIX "")

install(TARGETS perl_ktexteditor DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/KTextEditor/)