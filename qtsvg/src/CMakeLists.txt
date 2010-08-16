include_directories(
    ${CMAKE_SOURCE_DIR}/smoke
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on QtSvg4.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/QtSvg4.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} QtSvg4.xs ${CMAKE_CURRENT_BINARY_DIR}/QtSvg4.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/QtSvg4.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build QtSvg4.c as c++ code
set(CMAKE_C_COMPILER ${CMAKE_CXX_COMPILER})

set(CMAKE_C_FLAGS ${PERL_CXX_FLAGS})

set(qtsvg4_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/QtSvg4.c
    qtsvg4handlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/QtSvg4)
add_library(qtsvg4 MODULE ${qtsvg4_LIBRARY_SRC})

target_link_libraries(qtsvg4
    ${QT_QTSVG_LIBRARY} 
    smokeqtsvg
    perlqtcore4)

set_target_properties(qtsvg4 PROPERTIES OUTPUT_NAME "QtSvg4")
set_target_properties(qtsvg4 PROPERTIES PREFIX "")

install(TARGETS qtsvg4 DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/QtSvg4/)
