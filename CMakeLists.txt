cmake_minimum_required(VERSION 2.8.11)

project(PerlQt)

if(MSVC)
    # Use all the cores
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP")
endif(MSVC)

set(MEMORYCHECK_COMMAND_OPTIONS "--trace-children=yes --leak-check=full --show-leak-kinds=definite --errors-for-leak-kinds=definite")
find_program(MEMORYCHECK_COMMAND NAMES valgrind)
include(CTest)

set(BUILD_TESTS OFF CACHE BOOL "Build tests")
set(ENABLE_GUI_TESTS OFF CACHE BOOL "Run GUI tests in the \"test\" target")
set(USE_BUILD_DIR_FOR_TESTS OFF CACHE BOOL "Use to toggle between using the build dir or the install dir for tests.")

find_package(Perl REQUIRED)
find_package(PerlLibs REQUIRED)
find_package(Qt5 COMPONENTS Core REQUIRED)
find_package(Qt5
    COMPONENTS
    DBus
    Gui
    Help
    Network
    Sql
    Widgets
    QUIET
)

find_package(Smoke REQUIRED COMPONENTS QtCore)
find_package(Smoke
    COMPONENTS
    QtDBus
    QtGui
    QtHelp
    QtNetwork
    QtSql
    QtWidgets
    QUIET
)

include_directories(
    ${SMOKE_INCLUDE_DIR}
    ${SMOKE_QTCORE_INCLUDE_DIR}
    ${CMAKE_SOURCE_DIR}/src
)
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${SMOKE_CMAKE_MODULE_DIR})
include(MacroOptionalFindPackage)
include(MacroOptionalAddBindings)
include(MacroLogFeature)
include(MacroProve)
find_package(PerlMore)
find_package(XSUBPP REQUIRED QUIET)

if (CMAKE_BUILD_TYPE STREQUAL "Coverage")
    set(BUILD_TESTS ON CACHE BOOL "Build tests" FORCE)
    enable_testing()

    include(CodeCoverage)
    setup_target_for_coverage(
        coverage
        ctest
        coverage
    )
else()
    if (BUILD_TESTS)
        enable_testing()
    endif()
endif()

string(LENGTH "${PERL_INSTALL_PREFIX}" PERL_INSTALL_PREFIX_LEN)
math(EXPR PERL_INSTALL_PREFIX_LEN "${PERL_INSTALL_PREFIX_LEN}+1")
string(LENGTH "${PERL_SITE_ARCH_DIR}" PERL_SITE_ARCH_DIR_LEN)
math(EXPR CUSTOM_PERL_SITE_ARCH_DIR_SUBSTRING_LEN "${PERL_SITE_ARCH_DIR_LEN}-${PERL_INSTALL_PREFIX_LEN}")
string(SUBSTRING ${PERL_SITE_ARCH_DIR} ${PERL_INSTALL_PREFIX_LEN} ${CUSTOM_PERL_SITE_ARCH_DIR_SUBSTRING_LEN} CUSTOM_PERL_SITE_ARCH_DIR)
file(TO_NATIVE_PATH "${CMAKE_INSTALL_PREFIX}/${CUSTOM_PERL_SITE_ARCH_DIR}" CUSTOM_PERL_SITE_ARCH_DIR)
set(CUSTOM_PERL_SITE_ARCH_DIR ${CUSTOM_PERL_SITE_ARCH_DIR} CACHE DIR "Custom installation directory for perl binary extension")

# the RPATH to be used when installing, but only if it's not a system directory
GET_FILENAME_COMPONENT(SMOKE_LIB_DIR ${SMOKE_BASE_LIBRARY} PATH)
LIST(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES ${SMOKE_LIB_DIR} isSystemDir)
IF("${isSystemDir}" STREQUAL "-1")
   SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_RPATH}:${SMOKE_LIB_DIR}")
ENDIF("${isSystemDir}" STREQUAL "-1")

GET_FILENAME_COMPONENT(PERL_LIB_DIR ${PERL_LIBRARY} PATH)
LIST(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES ${PERL_LIB_DIR} isSystemDir)
IF("${isSystemDir}" STREQUAL "-1")
   SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_RPATH}:${PERL_LIB_DIR}")
ENDIF("${isSystemDir}" STREQUAL "-1")

get_target_property(QtCore_location Qt5::Core LOCATION)
GET_FILENAME_COMPONENT(QtCore_lib_dir ${QtCore_location} PATH)
LIST(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES ${QtCore_lib_dir} isSystemDir)
IF("${isSystemDir}" STREQUAL "-1")
    SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_RPATH}:${QtCore_lib_dir}")
ENDIF("${isSystemDir}" STREQUAL "-1")

if (NOT LIB_INSTALL_DIR)
    set (LIB_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/lib${LIB_SUFFIX})
endif (NOT LIB_INSTALL_DIR)

add_subdirectory(src)
add_subdirectory(modules)

macro_display_feature_log()

#install(EXPORT PerlQtExport DESTINATION ${CMAKE_INSTALL_PREFIX}/share/perlqt/cmake NAMESPACE PERLQT_)
add_subdirectory(cmake)
