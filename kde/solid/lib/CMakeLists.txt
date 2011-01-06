add_custom_target(solidpm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/Solid.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/Solid.pm)
install(FILES Solid.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
