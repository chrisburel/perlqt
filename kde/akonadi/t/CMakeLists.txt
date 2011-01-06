enable_testing()
set(prove_args -I${CMAKE_BINARY_DIR}/perl/blib/lib -I${CMAKE_BINARY_DIR}/perl/blib/arch)

# Class tests
add_test(perlqt_akonadi_load prove ${prove_args} ${CMAKE_CURRENT_SOURCE_DIR}/a_loading.t)