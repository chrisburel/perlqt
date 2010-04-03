add_custom_target(plasma4pm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/Plasma4.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/Plasma4.pm)
install(FILES Plasma4.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
