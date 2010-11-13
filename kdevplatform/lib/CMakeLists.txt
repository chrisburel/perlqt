add_custom_target(kdevplatformpm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/KDevPlatform.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/KDevPlatform.pm)
install(FILES KDevPlatform.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
