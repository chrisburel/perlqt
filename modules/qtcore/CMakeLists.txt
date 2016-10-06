xsubpp(qtcore.xs ${CMAKE_CURRENT_BINARY_DIR}/qtcore.cpp)

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${PERL_INCLUDE_PATH}
)

add_definitions("-DPERLQT_QT_VERSION=${Qt5Core_VERSION}")

set(CMAKE_CXX_FLAGS ${PERL_CXX_FLAGS})

if(WIN32)
    set(libraryName PerlQtCore)
else()
    set(libraryName QtCore)
endif(WIN32)
set(LIBRARY_OUTPUT_PATH ${CMAKE_BINARY_DIR}/blib/arch/auto/PerlQt5/${libraryName})

add_library(perlqtcore5 SHARED
    ${CMAKE_CURRENT_BINARY_DIR}/qtcore.cpp
    invokeslot.cpp
    perlqtmetaobject.cpp
    qtcore_handlers.cpp
)

target_link_libraries(perlqtcore5
    Qt5::Core
    ${PERL_LIBRARY}
    ${SMOKE_BASE_LIBRARY}
    ${SMOKE_QTCORE_LIBRARY}
    ${PERL_LIBS}
    smokeperl
)

set_target_properties(perlqtcore5 PROPERTIES
    OUTPUT_NAME ${libraryName}
    PREFIX ""
    INSTALL_NAME_DIR ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

install(
    TARGETS perlqtcore5
    EXPORT PerlQtExport
    DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/auto/PerlQt5/${libraryName}/
)

add_custom_target(
    perlqt5corepm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtCore.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5/QtCore.pm
)

add_subdirectory(tests)
