enable_testing()
set(prove_args -I../../blib/lib -I../../blib/arch)
add_test(perlqt_qsignalspy prove ${prove_args} ${CMAKE_CURRENT_SOURCE_DIR}/qsignalspy.t)
add_test(perlqt_qtesteventlist prove ${prove_args} ${CMAKE_CURRENT_SOURCE_DIR}/qtesteventlist.t)

