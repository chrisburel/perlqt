function(addTestsFromTFiles)
    file(GLOB testFiles *.t)
    list(SORT testFiles)
    foreach(testFile ${testFiles})
        get_filename_component(testName "${testFile}" NAME_WE)
        macro_prove(${testName} ${testFile})
    endforeach()
endfunction()

add_subdirectory(smokeperl)
add_subdirectory(perlqt5)
add_subdirectory(qtcore)
macro_optional_add_bindings(SMOKE_QTDBUS_FOUND              "QtDBus"              qtdbus)
macro_optional_add_bindings(SMOKE_QTGUI_FOUND               "QtGui"               qtgui)
macro_optional_add_bindings(SMOKE_QTHELP_FOUND              "QtHelp"              qthelp)
macro_optional_add_bindings(SMOKE_QTMULTIMEDIA_FOUND        "QtMultimedia"        qtmultimedia)
macro_optional_add_bindings(SMOKE_QTMULTIMEDIAWIDGETS_FOUND "QtMultimediaWidgets" qtmultimediawidgets)
macro_optional_add_bindings(SMOKE_QTNETWORK_FOUND           "QtNetwork"           qtnetwork)
macro_optional_add_bindings(SMOKE_QTOPENGL_FOUND            "QtOpenGL"            qtopengl)
macro_optional_add_bindings(SMOKE_QTPOSITIONING_FOUND       "QtPositioning"       qtpositioning)
macro_optional_add_bindings(SMOKE_QTPRINTSUPPORT_FOUND      "QtPrintSupport"      qtprintsupport)
macro_optional_add_bindings(SMOKE_QTQML_FOUND               "QtQml"               qtqml)
macro_optional_add_bindings(SMOKE_QTQUICK_FOUND             "QtQuick"             qtquick)
macro_optional_add_bindings(SMOKE_QTQUICKWIDGETS_FOUND      "QtQuickWidgets"      qtquickwidgets)
macro_optional_add_bindings(SMOKE_QTSCRIPT_FOUND            "QtScript"            qtscript)
macro_optional_add_bindings(SMOKE_QTSQL_FOUND               "QtSql"               qtsql)
macro_optional_add_bindings(SMOKE_QTSVG_FOUND               "QtSvg"               qtsvg)
macro_optional_add_bindings(SMOKE_QTTEST_FOUND              "QtTest"              qttest)
macro_optional_add_bindings(SMOKE_QTUITOOLS_FOUND           "QtUiTools"           qtuitools)
macro_optional_add_bindings(SMOKE_QTWEBCHANNEL_FOUND        "QtWebChannel"        qtwebchannel)
macro_optional_add_bindings(SMOKE_QTWEBENGINECORE_FOUND     "QtWebEngineCore"     qtwebenginecore)
macro_optional_add_bindings(SMOKE_QTWEBENGINEWIDGETS_FOUND  "QtWebEngineWidgets"  qtwebenginewidgets)
macro_optional_add_bindings(SMOKE_QTWIDGETS_FOUND           "QtWidgets"           qtwidgets)
macro_optional_add_bindings(SMOKE_QTXML_FOUND               "QtXml"               qtxml)
macro_optional_add_bindings(SMOKE_QTXMLPATTERNS_FOUND       "QtXmlPatterns"       qtxmlpatterns)

macro_display_bindings_log()
