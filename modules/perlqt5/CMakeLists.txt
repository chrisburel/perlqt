add_custom_target(
    perlqt5pm ALL
    ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/PerlQt5.pm ${CMAKE_BINARY_DIR}/blib/lib/PerlQt5.pm
)
