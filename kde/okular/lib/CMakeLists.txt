add_custom_target(okularpm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/Okular.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/Okular.pm)
install(FILES Okular.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
