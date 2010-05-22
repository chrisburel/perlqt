add_custom_target(kdecore4pm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/KDECore4.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/KDECore4.pm)
install(FILES KDECore4.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
