include_directories(
    ${CMAKE_SOURCE_DIR}/smoke
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on QtUiTools4.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/QtUiTools4.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} QtUiTools4.xs ${CMAKE_CURRENT_BINARY_DIR}/QtUiTools4.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/QtUiTools4.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build QtUiTools4.c as c++ code
set(CMAKE_C_COMPILER ${CMAKE_CXX_COMPILER})

set(CMAKE_C_FLAGS ${PERL_CXX_FLAGS})

set(qtuitools4_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/QtUiTools4.c
    qtuitools4handlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/QtUiTools4)
add_library(qtuitools4 MODULE ${qtuitools4_LIBRARY_SRC})

target_link_libraries(qtuitools4
    ${QT_QTUITOOLS_LIBRARY} 
    smokeqtuitools
    perlqtcore4)

set_target_properties(qtuitools4 PROPERTIES OUTPUT_NAME "QtUiTools4")
set_target_properties(qtuitools4 PROPERTIES PREFIX "")

install(TARGETS qtuitools4 DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/QtUiTools4/)
