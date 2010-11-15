add_custom_target(sopranoclientpm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/SopranoClient.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/SopranoClient.pm)
install(FILES SopranoClient.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
