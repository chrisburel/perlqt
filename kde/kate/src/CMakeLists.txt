include_directories(
    ${CMAKE_SOURCE_DIR}/generator
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on Kate.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/Kate.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${PERLQT_SHARE_DIR}/doxsubpp.pl ${PERL_EXECUTABLE} Kate.xs ${CMAKE_CURRENT_BINARY_DIR}/Kate.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/Kate.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build Kate.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/Kate.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(kate_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/Kate.c
    katehandlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/Kate)
add_library(perl_kate MODULE ${kate_LIBRARY_SRC})

target_link_libraries(perl_kate
    ${SMOKE_KATE_LIBRARY}
    ${PERLQTCORE4_LIBRARY})

set_target_properties(perl_kate PROPERTIES OUTPUT_NAME "Kate")
set_target_properties(perl_kate PROPERTIES PREFIX "")

install(TARGETS perl_kate DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/Kate/)