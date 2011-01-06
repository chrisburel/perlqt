add_custom_target(atticapm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/Attica.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/Attica.pm)
install(FILES Attica.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
