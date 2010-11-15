include_directories(
    ${CMAKE_SOURCE_DIR}/smoke
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on Akonadi.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/Akonadi.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} Akonadi.xs ${CMAKE_CURRENT_BINARY_DIR}/Akonadi.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/Akonadi.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build Akonadi.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/Akonadi.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(akonadi_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/Akonadi.c
    akonadihandlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/Akonadi)
add_library(perl_akonadi MODULE ${akonadi_LIBRARY_SRC})

target_link_libraries(perl_akonadi
    smokeakonadi
    perlqtcore4)

set_target_properties(perl_akonadi PROPERTIES OUTPUT_NAME "Akonadi")
set_target_properties(perl_akonadi PROPERTIES PREFIX "")

install(TARGETS perl_akonadi DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/Akonadi/)