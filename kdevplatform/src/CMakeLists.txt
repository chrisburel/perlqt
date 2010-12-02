include_directories(
    ${CMAKE_SOURCE_DIR}/generator
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on KDevPlatform.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/KDevPlatform.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} KDevPlatform.xs ${CMAKE_CURRENT_BINARY_DIR}/KDevPlatform.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/KDevPlatform.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build KDevPlatform.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/KDevPlatform.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(kdevplatform_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/KDevPlatform.c
    kdevplatformhandlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/KDevPlatform)
add_library(perl_kdevplatform MODULE ${kdevplatform_LIBRARY_SRC})

target_link_libraries(perl_kdevplatform
    smokekdevplatform
    perlqtcore4)

set_target_properties(perl_kdevplatform PROPERTIES OUTPUT_NAME "KDevPlatform")
set_target_properties(perl_kdevplatform PROPERTIES PREFIX "")

install(TARGETS perl_kdevplatform DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/KDevPlatform/)