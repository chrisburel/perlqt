add_subdirectory( Qt )
add_custom_target(perlqt4pm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/Qt.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/Qt.pm)
install( FILES Qt.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR} )
