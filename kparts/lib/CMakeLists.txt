add_custom_target(kpartspm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/KParts.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/KParts.pm)
install(FILES KParts.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
