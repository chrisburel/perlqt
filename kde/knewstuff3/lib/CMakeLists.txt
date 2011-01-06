add_custom_target(knewstuff3pm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/KNewStuff3.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/KNewStuff3.pm)
install(FILES KNewStuff3.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
