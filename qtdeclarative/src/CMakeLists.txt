include_directories(
    ${CMAKE_SOURCE_DIR}/smoke
    ${CMAKE_SOURCE_DIR}/perl/qtcore/src
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on QtDeclarative4.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/QtDeclarative4.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/qtcore/src/doxsubpp.pl ${PERL_EXECUTABLE} QtDeclarative4.xs ${CMAKE_CURRENT_BINARY_DIR}/QtDeclarative4.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/QtDeclarative4.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build QtDeclarative4.c as c++ code
set(CMAKE_C_COMPILER ${CMAKE_CXX_COMPILER})

set(CMAKE_C_FLAGS ${PERL_CXX_FLAGS})

set(qtdeclarative4_LIBRARY_SRC
    ${CMAKE_CURRENT_BINARY_DIR}/QtDeclarative4.c
    qtdeclarative4handlers.cpp
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/QtDeclarative4)
add_library(qtdeclarative4 MODULE ${qtdeclarative4_LIBRARY_SRC})

target_link_libraries(qtdeclarative4
    ${QT_QTDECLARATIVE_LIBRARY} 
    smokeqtdeclarative
    perlqtcore4)

set_target_properties(qtdeclarative4 PROPERTIES OUTPUT_NAME "QtDeclarative4")
set_target_properties(qtdeclarative4 PROPERTIES PREFIX "")

install(TARGETS qtdeclarative4 DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/QtDeclarative4/)
