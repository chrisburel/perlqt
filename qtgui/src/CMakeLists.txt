include_directories(
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${CMAKE_SOURCE_DIR}/smoke
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on QtGui4.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/QtGui4.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} QtGui4.xs ${CMAKE_CURRENT_BINARY_DIR}/QtGui4.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/QtGui4.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_definitions( -DDEBUG )

# Make sure we build QtGui4.c as c++ code
set(CMAKE_C_COMPILER ${CMAKE_CXX_COMPILER})

set(CMAKE_C_FLAGS ${PERL_CXX_FLAGS})

set(perlqtgui4_LIBRARY_SRCS
    ${CMAKE_CURRENT_BINARY_DIR}/QtGui4.c
    qtgui4handlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/QtGui4)
add_library(perlqtgui4 SHARED ${perlqtgui4_LIBRARY_SRCS})

target_link_libraries(perlqtgui4
    ${QT_QTNETWORK_LIBRARY} 
    ${QT_QTSQL_LIBRARY} 
    ${QT_QTOPENGL_LIBRARY} 
    ${QT_QTXML_LIBRARY} 
    ${QT_QTSVG_LIBRARY} 
    smokeqtgui
    smokeqtcore
    perlqtcore4
    ${PERL_LIBS})

set_target_properties(perlqtgui4 PROPERTIES OUTPUT_NAME "QtGui4")
set_target_properties(perlqtgui4 PROPERTIES PREFIX "")

install(TARGETS perlqtgui4 DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/QtGui4/)
