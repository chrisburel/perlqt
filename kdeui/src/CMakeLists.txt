include_directories(
    ${CMAKE_SOURCE_DIR}/generator
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${KDE4_INCLUDE_DIR}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on KDEUi4.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/KDEUi4.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} KDEUi4.xs ${CMAKE_CURRENT_BINARY_DIR}/KDEUi4.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/KDEUi4.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build KDEUi4.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/KDEUi4.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(kdeui4_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/KDEUi4.c
    kdeui4handlers.cpp
)

set(factory_SRCS
    kperlpluginfactory.cpp)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/KDEUi4)
add_library(perl_kdeui4 MODULE ${kdeui4_LIBRARY_SRC})

target_link_libraries(perl_kdeui4
    smokekdeui
    perlqtcore4)

set_target_properties(perl_kdeui4 PROPERTIES OUTPUT_NAME "KDEUi4")
set_target_properties(perl_kdeui4 PROPERTIES PREFIX "")

kde4_add_plugin(kperlpluginfactory ${factory_SRCS})
set_target_properties(kperlpluginfactory PROPERTIES 
    LINK_FLAGS ${PERL_CCDL_FLAGS}
    COMPILE_FLAGS ${PERL_CXX_FLAGS} )
target_link_libraries(kperlpluginfactory
    ${KDE4_KDECORE_LIBS}
    ${PERL_LIBRARY}
    ${PERL_LIBS}
    )

install(TARGETS perl_kdeui4 DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/KDEUi4/)
install(TARGETS kperlpluginfactory DESTINATION ${PLUGIN_INSTALL_DIR})
