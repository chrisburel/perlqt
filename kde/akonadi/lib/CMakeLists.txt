add_custom_target(akonadipm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/Akonadi.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/Akonadi.pm)
install(FILES Akonadi.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
