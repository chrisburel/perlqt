enable_testing()
set(prove_args -I../../blib/lib -I../../blib/arch)

# Class tests
add_test(perlqt_qstringlistmodel   prove ${prove_args} ${CMAKE_CURRENT_SOURCE_DIR}/qstringlistmodel.t)

# GUI tests
add_test(perlqt_mainwindowsmdi      prove ${prove_args} -I${CMAKE_SOURCE_DIR}/perl/qtgui/examples/mainwindows/mdi ${CMAKE_CURRENT_SOURCE_DIR}/mainwindowsmdi.t)
add_test(perlqt_paintingfontsampler prove ${prove_args} -I${CMAKE_SOURCE_DIR}/perl/qtgui/examples/painting/fontsampler ${CMAKE_CURRENT_SOURCE_DIR}/paintingfontsampler.t)
add_test(perlqt_widgetscalculator   prove ${prove_args} -I${CMAKE_SOURCE_DIR}/perl/qtgui/examples/widgets/calculator ${CMAKE_CURRENT_SOURCE_DIR}/widgetscalculator.t)
add_test(perlqt_xmlstreambookmarks  prove ${prove_args} -I${CMAKE_SOURCE_DIR}/perl/qtgui/examples/xml/streambookmarks ${CMAKE_CURRENT_SOURCE_DIR}/xmlstreambookmarks.t)
