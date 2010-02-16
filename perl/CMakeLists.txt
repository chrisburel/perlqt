option(ENABLE_PERLQT "build PerlQt" ON)

set(PERLQT_ENABLED "no")
if(ENABLE_PERLQT)
    set(PERLQT_ENABLED "yes")
endif(ENABLE_PERLQT)

if(PERLQT_ENABLED)
    include (FindPerlMore)

    SET(CUSTOM_PERL_SITE_ARCH_DIR ${PERL_SITE_ARCH_DIR} CACHE DIR "Custom installation directory for perl binary extension" )

    add_subdirectory(lib)

    include_directories( ${CMAKE_SOURCE_DIR}/smoke ${PERL_INCLUDE_PATH} )
    include_directories( ${QT_INCLUDES} )

# Run doxsubpp.pl to run xsubpp on Qt.xs
    add_custom_command(OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/Qt.cpp
                       COMMAND ${PERL_EXECUTABLE} ARGS ${CMAKE_CURRENT_SOURCE_DIR}/doxsubpp.pl ${PERL_EXECUTABLE}
                       DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/Qt.xs
                       WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )

    set(perlqt_LIB_SRCS
        binding.cpp
        handlers.cpp
        marshall_types.cpp
        Qt.cpp
    )

    set(LIBRARY_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR}/blib/arch/auto/Qt)
    add_library(perlqt4 SHARED ${perlqt_LIB_SRCS})

    target_link_libraries(perlqt4 ${QT_QTCORE_LIBRARY} ${PERL_LIBRARY} ${QT_QTNETWORK_LIBRARY} smokeqt)
    set_target_properties(perlqt4 PROPERTIES OUTPUT_NAME "Qt")
    set_target_properties(perlqt4 PROPERTIES PREFIX "")

    install( TARGETS perlqt4 DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/Qt )
endif(PERLQT_ENABLED)

message(STATUS "Build PerlQt... " ${PERLQT_ENABLED})
