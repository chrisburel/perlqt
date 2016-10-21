
FUNCTION( MACRO_PROVE _testname _path)

    get_filename_component(perl_basedir ${PERL_EXECUTABLE} DIRECTORY)

    find_program(
        prove_cmd
        NAMES prove prove.bat
        HINTS ${perl_basedir}
    )

    if(WIN32)
        string(REGEX REPLACE " " "\\\\\\\\ " escaped_path ${_path})
    else()
        set(escaped_path ${_path})
    endif(WIN32)

    set(prove_args ${prove_cmd})
    if ( USE_BUILD_DIR_FOR_TESTS )
        list(APPEND prove_args -I${CMAKE_BINARY_DIR}/blib/lib -I${CMAKE_BINARY_DIR}/blib/arch)
    endif ( USE_BUILD_DIR_FOR_TESTS )

    set(exe ${PERL_EXECUTABLE})

    set(_workingdir ${ARGV2})
    if(_workingdir)
        set(prove_args -E chdir ${_workingdir} ${PERL_EXECUTABLE} ${prove_cmd} ${prove_args})
        set(exe ${CMAKE_COMMAND})
    endif(_workingdir)

    add_test(${_testname} ${exe} ${prove_args} ${escaped_path})
ENDFUNCTION( MACRO_PROVE _testname _path )
