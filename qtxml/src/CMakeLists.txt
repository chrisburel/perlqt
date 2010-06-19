include_directories(
    ${CMAKE_SOURCE_DIR}/smoke
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on QtXml4.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/QtXml4.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} QtXml4.xs ${CMAKE_CURRENT_BINARY_DIR}/QtXml4.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/QtXml4.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build QtXml4.c as c++ code
set(CMAKE_C_COMPILER ${CMAKE_CXX_COMPILER})

set(CMAKE_C_FLAGS ${PERL_CXX_FLAGS})

set(qtxml4_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/QtXml4.c
    qtxml4handlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/QtXml4)
add_library(qtxml4 MODULE ${qtxml4_LIBRARY_SRC})

target_link_libraries(qtxml4
    ${QT_QTXML_LIBRARY} 
    smokeqtxml
    perlqtcore4)

set_target_properties(qtxml4 PROPERTIES OUTPUT_NAME "QtXml4")
set_target_properties(qtxml4 PROPERTIES PREFIX "")

install(TARGETS qtxml4 DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/QtXml4/)
