include_directories(
    ${CMAKE_SOURCE_DIR}/smoke
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on NepomukQuery.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/NepomukQuery.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} NepomukQuery.xs ${CMAKE_CURRENT_BINARY_DIR}/NepomukQuery.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/NepomukQuery.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build NepomukQuery.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/NepomukQuery.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(nepomukquery_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/NepomukQuery.c
    nepomukqueryhandlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/NepomukQuery)
add_library(perl_nepomukquery MODULE ${nepomukquery_LIBRARY_SRC})

target_link_libraries(perl_nepomukquery
    smokenepomukquery
    perlqtcore4)

set_target_properties(perl_nepomukquery PROPERTIES OUTPUT_NAME "NepomukQuery")
set_target_properties(perl_nepomukquery PROPERTIES PREFIX "")

install(TARGETS perl_nepomukquery DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/NepomukQuery/)