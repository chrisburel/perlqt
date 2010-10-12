project(Perl)

find_package(Perl)
find_package(PerlLibs)

if (NOT PERL_FOUND OR NOT PERL_LIBRARY)
    return()
endif (NOT PERL_FOUND OR NOT PERL_LIBRARY)

add_definitions(-DDEBUG)

include (FindPerlMore)
set(CUSTOM_PERL_SITE_ARCH_DIR ${PERL_SITE_ARCH_DIR} CACHE DIR "Custom installation directory for perl binary extension")

add_subdirectory(qtcore)

macro_optional_add_bindings(QT_QTDBUS_FOUND        "QtDBus"        qtdbus)
macro_optional_add_bindings(QT_QTDECLARATIVE_FOUND "QtDeclarative" qtdeclarative)
macro_optional_add_bindings(QT_QTGUI_FOUND         "QtGui"         qtgui)
macro_optional_add_bindings(QT_QTHELP_FOUND        "QtHelp"        qthelp)
macro_optional_add_bindings(QT_QTMULTIMEDIA_FOUND  "QtMultimedia"  qtmultimedia)
macro_optional_add_bindings(QT_QTNETWORK_FOUND     "QtNetwork"     qtnetwork)
macro_optional_add_bindings(QT_QTOPENGL_FOUND      "QtOpenGL"      qtopengl)
macro_optional_add_bindings(QT_QTSCRIPT_FOUND      "QtScript"      qtscript)
macro_optional_add_bindings(QT_QTSQL_FOUND         "QtSql"         qtsql)
macro_optional_add_bindings(QT_QTSVG_FOUND         "QtSvg"         qtsvg)
macro_optional_add_bindings(QT_QTTEST_FOUND        "QtTest"        qttest)
macro_optional_add_bindings(QT_QTUITOOLS_FOUND     "QtUiTools"     qtuitools)
macro_optional_add_bindings(QT_QTWEBKIT_FOUND      "QtWebKit"      qtwebkit)
macro_optional_add_bindings(QT_QTXML_FOUND         "QtXml"         qtxml)
macro_optional_add_bindings(QT_QTXMLPATTERNS_FOUND "QtXmlPatterns" qtxmlpatterns)

macro_optional_add_bindings(KDE4_FOUND "KDECore" kdecore)
macro_optional_add_bindings(KDE4_FOUND "KDEUi" kdeui)
macro_optional_add_bindings(KDE4_FOUND "KIO" kio)
macro_optional_add_bindings(KDE4_FOUND "Plasma" plasma)

macro_display_bindings_log()
