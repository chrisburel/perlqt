include_directories(
    ${CMAKE_SOURCE_DIR}/smoke
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on Nepomuk.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/Nepomuk.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} Nepomuk.xs ${CMAKE_CURRENT_BINARY_DIR}/Nepomuk.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/Nepomuk.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build Nepomuk.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/Nepomuk.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(nepomuk_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/Nepomuk.c
    nepomukhandlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/Nepomuk)
add_library(perl_nepomuk MODULE ${nepomuk_LIBRARY_SRC})

target_link_libraries(perl_nepomuk
    smokenepomuk
    perlqtcore4)

set_target_properties(perl_nepomuk PROPERTIES OUTPUT_NAME "Nepomuk")
set_target_properties(perl_nepomuk PROPERTIES PREFIX "")

install(TARGETS perl_nepomuk DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/Nepomuk/)