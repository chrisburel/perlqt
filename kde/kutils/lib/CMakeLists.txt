add_custom_target(kutilspm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/KUtils.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/KUtils.pm)
install(FILES KUtils.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
