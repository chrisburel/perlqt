add_custom_target(knewstuff2pm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/KNewStuff2.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/KNewStuff2.pm)
install(FILES KNewStuff2.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
