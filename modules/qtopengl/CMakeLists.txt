xsubpp(qtopengl.xs ${CMAKE_CURRENT_BINARY_DIR}/qtopengl.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions(${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtOpenGL)
else()
    set(libraryName QtOpenGL)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtopengl5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtopengl.cpp
)

target_link_libraries(perlqtopengl5
    Qt5::OpenGL
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    ${SMOKE_QTOPENGL_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtopengl5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtopengl5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5openglpm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtOpenGL.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtOpenGL.pm
)
install(FILES QtOpenGL.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/PerlQt5)

add_subdirectory(tests)
