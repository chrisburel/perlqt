add_custom_target(
    perlqt5pm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/PerlQt5.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5.pm
)

install(FILES PerlQt5.pm DESTINATION ${CUSTOM_PERL_SITE_ARCH_DIR})
