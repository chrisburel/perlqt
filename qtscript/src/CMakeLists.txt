include_directories(
    ${CMAKE_SOURCE_DIR}/smoke
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on QtScript4.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/QtScript4.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} QtScript4.xs ${CMAKE_CURRENT_BINARY_DIR}/QtScript4.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/QtScript4.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build QtScript4.c as c++ code
set(CMAKE_C_COMPILER ${CMAKE_CXX_COMPILER})

set(CMAKE_C_FLAGS ${PERL_CXX_FLAGS})

set(qtscript4_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/QtScript4.c
    qtscript4handlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/QtScript4)
add_library(qtscript4 MODULE ${qtscript4_LIBRARY_SRC})

target_link_libraries(qtscript4
    ${QT_QTSCRIPT_LIBRARY} 
    smokeqtscript
    perlqtcore4)

set_target_properties(qtscript4 PROPERTIES OUTPUT_NAME "QtScript4")
set_target_properties(qtscript4 PROPERTIES PREFIX "")

install(TARGETS qtscript4 DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/QtScript4/)
