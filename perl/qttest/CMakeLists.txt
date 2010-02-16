include_directories( ${CMAKE_SOURCE_DIR}/smoke ${PERL_INCLUDE_PATH} ${CMAKE_SOURCE_DIR}/perl/perlqt/src)
include_directories( ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on Qt4.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/QtTest4.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_SOURCE_DIR}/perl/perlqt4/src/doxsubpp.pl ${PERL_EXECUTABLE} QtTest4.xs QtTest4.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/QtTest4.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
# Make sure we build Qt4.c as c++ code
set(CMAKE_C_COMPILER ${CMAKE_CXX_COMPILER})

set(CMAKE_C_FLAGS ${PERL_CXX_FLAGS})

set(perlqttest4_LIBRARY_SRC QtTest4.c qttest4handlers.cpp)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/QtTest4)
add_library(perlqttest4 MODULE ${perlqttest4_LIBRARY_SRC})
target_link_libraries(perlqttest4 ${QT_QTCORE_LIBRARY} smokeqt smokeqttest perlqt4)
set_target_properties(perlqttest4 PROPERTIES OUTPUT_NAME "QtTest4")
set_target_properties(perlqttest4 PROPERTIES PREFIX "")

add_custom_target(perlqttest4pm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtTest4.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/QtTest4.pm)
install(TARGETS perlqttest4 DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/QtTest4/)
install(FILES QtTest4.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
