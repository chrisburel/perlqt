include_directories(
    ${CMAKE_SOURCE_DIR}/smoke
    ${CMAKE_SOURCE_DIR}/perl/perlqt/src
    ${PERL_INCLUDE_PATH}
    ${KDE4_INCLUDE_DIR}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on KIO4.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/KIO4.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/perlqt/src/doxsubpp.pl ${PERL_EXECUTABLE} KIO4.xs ${CMAKE_CURRENT_BINARY_DIR}/KIO4.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/KIO4.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build KIO4.c as c++ code
set(CMAKE_C_COMPILER ${CMAKE_CXX_COMPILER})

set(CMAKE_C_FLAGS ${PERL_CXX_FLAGS})

set(kio4_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/KIO4.c
    kio4handlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/KIO4)
add_library(kio4 MODULE ${kio4_LIBRARY_SRC})

target_link_libraries(kio4
    ${QT_QTNETWORK_LIBRARY} 
    ${QT_QTSQL_LIBRARY} 
    ${QT_QTOPENGL_LIBRARY} 
    ${QT_QTXML_LIBRARY} 
    ${QT_QTSVG_LIBRARY} 
    ${KDE4_KDECORE_LIBS}
    ${KDE4_KIO_LIBS}
    smokekio
    perlqtcore4)

set_target_properties(kio4 PROPERTIES OUTPUT_NAME "KIO4")
set_target_properties(kio4 PROPERTIES PREFIX "")

install(TARGETS kio4 DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/KIO4/)
