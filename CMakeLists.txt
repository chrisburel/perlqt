project(kdebindings)

# where to look first for cmake modules, before ${CMAKE_ROOT}/Modules/ is checked
set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake/modules )

include (MacroOptionalFindPackage)

FIND_PACKAGE(Perl REQUIRED)
FIND_PACKAGE (Qt4 REQUIRED)

add_definitions (${QT_DEFINITIONS}  -DHAVE_CONFIG_H=1)
include_directories (${CMAKE_SOURCE_DIR} ${CMAKE_BINARY_DIR} ${QT_INCLUDES} )

FIND_PACKAGE (OpenGL REQUIRED)

add_subdirectory(smoke)
add_subdirectory(perl)

# 3. Build kdebindings with command like:
#      cmake
#        -DCMAKE_INSTALL_PREFIX=/opt/ruby1.8.7                          \
#        -DRUBY_EXECUTABLE=/opt/ruby1.8.7/bin/ruby                      \
#        -DRUBY_INCLUDE_PATH=/opt/ruby1.8.7/lib/ruby/1.8/i686-linux/    \
#        -Wno-dev                                                       \
#        -DENABLE_SMOKE=on                                              \
#        -DENABLE_QTRUBY=on                                             \
#        -DENABLE_QTWEBKIT_SMOKE=off                                    \
#        -DENABLE_QTSCRIPT_SMOKE=off                                    \
#        -DENABLE_QTUITOOLS_SMOKE=off                                   \
#        -DENABLE_QTTEST_SMOKE=off                                      \
#        -DENABLE_PHONON_SMOKE=off                                      \
#        -DENABLE_QSCI_SMOKE=off                                        \
#        -DENABLE_QWT_SMOKE=off                                         \
#        -DENABLE_KDE_SMOKE=off                                         \
#        -DENABLE_KDEVPLATFORM_SMOKE=off                                \
#        -DENABLE_KHTML_SMOKE=off                                       \
#        -DENABLE_KTEXTEDITOR_SMOKE=off                                 \
#        -DENABLE_SOLID_SMOKE=off                                       \
#        -DENABLE_PLASMA_SMOKE=off                                      \
#        -DENABLE_QTWEBKIT_RUBY=off                                     \
#        -DENABLE_QTUITOOLS_RUBY=off                                    \
#        -DENABLE_QTSCRIPT=off                                          \
#        -DENABLE_QTTEST=off                                            \
#        -DENABLE_PHONON_RUBY=off                                       \
#        -DENABLE_QSCINTILLA_RUBY=off                                   \
#        -DENABLE_QWT_RUBY=off                                          \
#        -DENABLE_SOPRANO_RUBY=off                                      \
#        -DENABLE_KDEVPLATFORM_RUBY=off                                 \
#        -DENABLE_KORUNDUM_RUBY=off                                     \
#        -DENABLE_KHTML_RUBY=off                                        \
#        -DENABLE_KTEXTEDITOR_RUBY=off                                  \
#        -DENABLE_SOLID_RUBY=off                                        \
#        -DENABLE_KROSSRUBY=off                                         \
#        -DENABLE_PLASMA_RUBY=off
# 4. If you need to clean the tree, use:
#      make clean
#      rm CMakeCache.txt CMakeFiles/*log
#

