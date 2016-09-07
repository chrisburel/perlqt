cmake_minimum_required(VERSION 2.8.11)

project(PerlQt)

enable_testing()
set(ENABLE_GUI_TESTS OFF CACHE BOOL "Run GUI tests in the \"test\" target")
set(USE_BUILD_DIR_FOR_TESTS OFF CACHE BOOL "Use to toggle between using the build dir or the install dir for tests.")

find_package(Perl REQUIRED)
find_package(PerlLibs REQUIRED)
find_package(Qt5Core REQUIRED)
find_package(Qt5 COMPONENTS Gui Widgets)
find_package(Smoke REQUIRED COMPONENTS QtCore)
find_package(Smoke COMPONENTS QtGui QtWidgets)

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

## This assumes there will be a release version of the qtcore library available
#GET_FILENAME_COMPONENT(QT_LIB_DIR ${QT_QTCORE_LIBRARY_RELEASE} PATH)
#LIST(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES ${QT_LIB_DIR} isSystemDir)
#IF("${isSystemDir}" STREQUAL "-1")
#   SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_RPATH}:${QT_LIB_DIR}")
#ENDIF("${isSystemDir}" STREQUAL "-1")

add_subdirectory(src)
add_subdirectory(modules)

macro_display_bindings_log()

macro_display_feature_log()

#install(EXPORT PerlQtExport DESTINATION ${CMAKE_INSTALL_PREFIX}/share/perlqt/cmake NAMESPACE PERLQT_)
add_subdirectory(cmake)
