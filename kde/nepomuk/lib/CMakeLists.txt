add_custom_target(nepomukpm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/Nepomuk.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/Nepomuk.pm)
install(FILES Nepomuk.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
