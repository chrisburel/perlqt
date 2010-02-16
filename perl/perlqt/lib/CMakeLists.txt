add_subdirectory( Qt4 )
add_custom_target(perlqt4pm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/Qt4.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/Qt4.pm)
install( FILES Qt4.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR} )
