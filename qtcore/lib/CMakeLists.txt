add_subdirectory( QtCore5 )
add_custom_target(perlqtcore4pm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/QtCore5.pm ${CMAKE_BINARY_DIR}/blib/lib/QtCore5.pm)
install( FILES QtCore5.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR} )
