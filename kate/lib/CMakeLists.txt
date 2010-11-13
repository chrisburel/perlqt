add_custom_target(katepm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/Kate.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/Kate.pm)
install(FILES Kate.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
