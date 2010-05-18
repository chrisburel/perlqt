#####################################################################
# PerlQt4

OPTION(ENABLE_PERLQT4 "build PerlQt4" ON)
OPTION(ENABLE_PERLQTCORE4 "build PerlQtCore4" ON)
OPTION(ENABLE_PERLQTGUI4 "build PerlQtGui4" ON)
OPTION(ENABLE_PERLQTTEST4 "build PerlQtTest4" ON)
OPTION(ENABLE_PERLKDECORE4 "build PerlKDECore4" ON)
OPTION(ENABLE_PERLKDEUI4 "build PerlKDEUi4" ON)
OPTION(ENABLE_PERLKIO4 "build PerlKIO4" ON)
OPTION(ENABLE_PERLPLASMA4 "build PerlPlasma4" ON)

add_definitions( -DDEBUG )
FIND_PACKAGE ( Perl )
FIND_PACKAGE ( PerlLibs )

include (FindPerlMore)
SET(CUSTOM_PERL_SITE_ARCH_DIR ${PERL_SITE_ARCH_DIR} CACHE DIR "Custom installation directory for perl binary extension" )

macro_optional_add_bindings(QT_QTCORE_FOUND "PerlQtCore" qtcore)
macro_optional_add_bindings(QT_QTGUI_FOUND "PerlQtGui" qtgui)
macro_optional_add_bindings(QT_QTTEST_FOUND "PerlQtTest" qttest)

macro_optional_add_bindings(KDE4_FOUND "PerlKDECore" kdecore)
macro_optional_add_bindings(KDE4_FOUND "PerlKDEUi" kdeui)
macro_optional_add_bindings(KDE4_FOUND "PerlKIO" kio)
macro_optional_add_bindings(KDE4_FOUND "PerlPlasma" plasma)

macro_display_bindings_log()
