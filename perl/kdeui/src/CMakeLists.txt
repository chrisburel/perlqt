include_directories(
    ${CMAKE_SOURCE_DIR}/smoke
    ${CMAKE_SOURCE_DIR}/perl/perlqt/src
    ${PERL_INCLUDE_PATH}
    ${KDE4_INCLUDE_DIR}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on KDEUi4.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/KDEUi4.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/perlqt/src/doxsubpp.pl ${PERL_EXECUTABLE} KDEUi4.xs ${CMAKE_CURRENT_BINARY_DIR}/KDEUi4.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/KDEUi4.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build KDEUi4.c as c++ code
set(CMAKE_C_COMPILER ${CMAKE_CXX_COMPILER})

set(CMAKE_C_FLAGS ${PERL_CXX_FLAGS})

set(kdeui4_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/KDEUi4.c
    kdeui4handlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/KDEUi4)
add_library(kdeui4 MODULE ${kdeui4_LIBRARY_SRC})

target_link_libraries(kdeui4
    ${QT_QTNETWORK_LIBRARY} 
    ${QT_QTSQL_LIBRARY} 
    ${QT_QTOPENGL_LIBRARY} 
    ${QT_QTXML_LIBRARY} 
    ${QT_QTSVG_LIBRARY} 
    ${KDE4_KDECORE_LIBS}
    smokekdeui
    perlqtcore4)

set_target_properties(kdeui4 PROPERTIES OUTPUT_NAME "KDEUi4")
set_target_properties(kdeui4 PROPERTIES PREFIX "")

install(TARGETS kdeui4 DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/KDEUi4/)
