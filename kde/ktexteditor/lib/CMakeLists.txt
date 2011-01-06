add_custom_target(ktexteditorpm ALL ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/KTextEditor.pm ${CMAKE_BINARY_DIR}/perl/blib/lib/KTextEditor.pm)
install(FILES KTextEditor.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR}/)
