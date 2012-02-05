if(WIN32)
    string(REGEX REPLACE " " "\\\\\\\\ " escaped_path ${CMAKE_CURRENT_SOURCE_DIR})
    message(${escaped_path})
else(WIN32)
    set(escaped_path ${CMAKE_CURRENT_SOURCE_DIR})
endif(WIN32)

add_test(perlqt_qtcore4_load              ${prove_cmd} ${prove_args} ${escaped_path}/a_loading.t)
add_test(perlqt_qtcore4_qapp              ${prove_cmd} ${prove_args} ${escaped_path}/c_qapp.t)
add_test(perlqt_qtcore4_sigslot           ${prove_cmd} ${prove_args} ${escaped_path}/d_sigslot.t)
add_test(perlqt_qtcore4_sigslot_inherit   ${prove_cmd} ${prove_args} ${escaped_path}/e_sigslot_inherit.t)
add_test(perlqt_qtcore4_handlers          ${prove_cmd} ${prove_args} ${escaped_path}/f_handlers.t)

add_test(perlqt_qabstractitemmodel ${prove_args} ${prove_args} ${escaped_path}/qabstractitemmodel.t)
