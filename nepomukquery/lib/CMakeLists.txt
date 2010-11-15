add_custom_target(nepomukquerypm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/NepomukQuery.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/NepomukQuery.pm)
install(FILES NepomukQuery.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
