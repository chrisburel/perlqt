include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/smoke
    ${PERL_INCLUDE_PATH}
    ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on QtCore4.xs
add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/QtCore4.c
                   COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_CURRENT_SOURCE_DIR}/doxsubpp.pl ${PERL_EXECUTABLE} QtCore4.xs ${CMAKE_CURRENT_BINARY_DIR}/QtCore4.c
                   DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/QtCore4.xs
                   WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

# I thought it'd be cool to be able to build the bindings without any runtime
# debugging compiled in.  But that turned out to not really be a good idea, as
# that information is useful in a lot of situations.
add_definitions( -DDEBUG )

# Make sure we build QtCore4.c as c++ code
set_source_files_properties( ${CMAKE_CURRENT_BINARY_DIR}/QtCore4.c 
    PROPERTIES LANGUAGE CXX
)

set( CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS} )

set(perlqtcore_LIBRARY_SRCS
    binding.cpp
    handlers.cpp
    marshall_types.cpp
    util.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/QtCore4.c
)

set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/perl/blib/arch/auto/QtCore4)
add_library(perlqtcore4 SHARED ${perlqtcore_LIBRARY_SRCS})

target_link_libraries(perlqtcore4
    ${QT_QTCORE_LIBRARY}
    ${QT_QTGUI_LIBRARY}
    ${QT_QTNETWORK_LIBRARY}
    ${QT_QTDBUS_LIBRARY}
    ${PERL_LIBRARY}
    smokebase
    smokeqtcore
    smokeqtgui
    smokeqtnetwork
    smokeqtdbus
    ${PERL_LIBS})

set_target_properties(perlqtcore4 PROPERTIES OUTPUT_NAME "QtCore4")
set_target_properties(perlqtcore4 PROPERTIES PREFIX "")

install(TARGETS perlqtcore4 DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/QtCore4/)
