include_directories(
    ${CMAKE_SOURCE_DIR}/smoke
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on Okular.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/Okular.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} Okular.xs ${CMAKE_CURRENT_BINARY_DIR}/Okular.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/Okular.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build Okular.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/Okular.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(okular_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/Okular.c
    okularhandlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/Okular)
add_library(perl_okular MODULE ${okular_LIBRARY_SRC})

target_link_libraries(perl_okular
    smokeokular
    perlqtcore4)

set_target_properties(perl_okular PROPERTIES OUTPUT_NAME "Okular")
set_target_properties(perl_okular PROPERTIES PREFIX "")

install(TARGETS perl_okular DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/Okular/)