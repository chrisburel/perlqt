add_custom_target(sopranoserverpm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/SopranoServer.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/SopranoServer.pm)
install(FILES SopranoServer.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
