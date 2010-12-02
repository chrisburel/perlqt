project(Perl)

find_package(Perl)
find_package(PerlLibs)

if (NOT PERL_FOUND OR NOT PERL_LIBRARY)
    return()
endif (NOT PERL_FOUND OR NOT PERL_LIBRARY)

macro_optional_find_package(QScintilla)
macro_log_feature(QSCINTILLA_FOUND "QScintilla2" "QScintilla2 libraries" "http://www.riverbankcomputing.co.uk/software/qscintilla/intro" FALSE "" "Needed to compile QScintilla2 bindings")

macro_optional_find_package(QImageBlitz)
macro_log_feature(QIMAGEBLITZ_FOUND "QImageBlitz" "QImageBlitz library" "http://www.kde.org" FALSE "" "Needed to compile QImageBlitz bindings")

macro_optional_find_package(Phonon)
macro_log_feature(PHONON_FOUND "Phonon" "Phonon multimedia framework" "http://www.kde.org" FALSE "" "Needed to compile Phonon bindings")

macro_optional_find_package(Soprano)
macro_log_feature(SOPRANO_FOUND "Soprano" "Soprano libraries" "http://soprano.sourceforge.net" FALSE "" "Needed to compile Soprano bindings")

macro_optional_find_package(Nepomuk)
macro_log_feature(NEPOMUK_FOUND "Nepomuk" "Nepomuk libraries" "http://www.kde.org" FALSE "" "Needed to compile Nepomuk bindings")

macro_optional_find_package(KdepimLibs)
macro_log_feature(KDEPIMLIBS_FOUND "kdepimlibs" "KDE PIM libraries" "http://www.kde.org" FALSE "" "Needed to compile Akonadi bindings")

macro_optional_find_package(Akonadi)
macro_log_feature(AKONADI_FOUND "Akonadi" "Akonadi libraries" "http://www.kde.org" FALSE "" "Needed to compile Akonadi bindings")

macro_optional_find_package(Okular)
macro_log_feature(OKULAR_FOUND "Okular" "Okular libraries" "http://www.kde.org" FALSE "" "Needed to compile Okular bindings")

macro_optional_find_package(LibAttica)
macro_log_feature(LIBATTICA_FOUND "libattica" "LibAttica" "http://www.kde.org" FALSE "" "Needed to compile libattica bindings")

macro_optional_find_package(Qwt5)
macro_log_feature(Qwt5_Qt4_FOUND "Qwt5 for Qt4" "Qwt5 libraries for Qt4" "http://qwt.sourceforge.net" FALSE "" "Needed to compile Qwt5 bindings")

add_definitions(-DDEBUG)

include (FindPerlMore)
set(CUSTOM_PERL_SITE_ARCH_DIR ${PERL_SITE_ARCH_DIR} CACHE DIR "Custom installation directory for perl binary extension")

add_subdirectory(qtcore)

macro_optional_add_bindings(QT_QT3SUPPORT_FOUND    "Qt3Support"    qt3support)
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

macro_optional_add_bindings(PHONON_FOUND "Phonon" phonon)

macro_optional_add_bindings(QSCINTILLA_FOUND "QScintilla" qsci)

macro_optional_add_bindings(Qwt5_Qt4_FOUND "Qwt" qwt)

macro_optional_add_bindings(QIMAGEBLITZ_FOUND "QImageBlitz" qimageblitz)

macro_optional_add_bindings(KDE4_FOUND "KDECore" kdecore)
macro_optional_add_bindings(KDE4_FOUND "KDEUi" kdeui)
macro_optional_add_bindings(KDE4_FOUND "KFile" kfile)
macro_optional_add_bindings(KDE4_FOUND "KHTML" khtml)
macro_optional_add_bindings(KDE4_FOUND "KIO" kio)
macro_optional_add_bindings(KDE4_FOUND "KNewStuff2" knewstuff2)
macro_optional_add_bindings(KDE4_FOUND "KNewStuff3" knewstuff3)
macro_optional_add_bindings(KDE4_FOUND "KParts" kparts)
macro_optional_add_bindings(KDE4_FOUND "KTextEditor" ktexteditor)
macro_optional_add_bindings(KDE4_FOUND "KUtils" kutils)
macro_optional_add_bindings(KDE4_FOUND "Plasma" plasma)
macro_optional_add_bindings(KDE4_FOUND "Solid" solid)

macro_optional_add_bindings(Soprano_FOUND "Soprano" soprano sopranoclient sopranoserver)

if(KDEPIMLIBS_FOUND AND Akonadi_FOUND)
    set(BUILD_Akonadi TRUE)
else(KDEPIMLIBS_FOUND AND Akonadi_FOUND)
    set(BUILD_Akonadi FALSE)
endif(KDEPIMLIBS_FOUND AND Akonadi_FOUND)
macro_optional_add_bindings(BUILD_Akonadi "Akonadi" akonadi)

macro_optional_add_bindings(LIBATTICA_FOUND "Attica" attica)

macro_optional_add_bindings(Nepomuk_FOUND "Nepomuk" nepomuk nepomukquery)

macro_optional_add_bindings(OKULAR_FOUND "Okular" okular)

find_library(KATEINTERFACES_LIBRARY kateinterfaces HINTS ${KDE4_LIB_DIR})
find_path(KATE_INCLUDE_DIR kate/plugin.h HINTS ${KDE4_INCLUDE_DIR})

macro_optional_add_bindings(KATE_INCLUDE_DIR "Kate" kate)

macro_display_bindings_log()
