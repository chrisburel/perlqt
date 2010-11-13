add_custom_target(sopranoserverpm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/SopranoCerver.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/SopranoCerver.pm)
install(FILES SopranoCerver.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
