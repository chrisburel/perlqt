find_package(Perl)

execute_process(
    COMMAND ${PERL_EXECUTABLE} -MExtUtils::MakeMaker -e
        "print ExtUtils::MakeMaker->new({NAME => '_', NEEDS_LINKING => 1})->tool_xsubpp()"
    OUTPUT_VARIABLE xsubppInfo
)

string(REPLACE "\n" ";" xsubppInfo ${xsubppInfo})
foreach(dir ${xsubppInfo})
    if (${dir} MATCHES "^XSUBPPDIR = ")
        string(REGEX REPLACE "^XSUBPPDIR = (.*)" \\1 XSUBPP_DIR ${dir})
    elseif (${dir} MATCHES "^XSUBPP = ")
        string(REGEX REPLACE "^XSUBPP = \"?(.*)" \\1 XSUBPP_SCRIPT ${dir})
        string(REGEX REPLACE "\"$" "" XSUBPP_SCRIPT ${XSUBPP_SCRIPT})
        string(REGEX REPLACE "\\$\\(XSUBPPDIR\\)" ${XSUBPP_DIR} XSUBPP_SCRIPT ${XSUBPP_SCRIPT})
        string(REGEX REPLACE "\\$\\(DFSEP\\)" / XSUBPP_SCRIPT ${XSUBPP_SCRIPT})
    elseif (${dir} MATCHES "^XSUBPPRUN = ")
        string(REGEX REPLACE "^XSUBPPRUN = (.*)" \\1 XSUBPP_EXECUTABLE ${dir})
        string(REGEX REPLACE "\\$\\(PERLRUN\\)" ${PERL_EXECUTABLE} XSUBPP_EXECUTABLE ${XSUBPP_EXECUTABLE})
        string(REGEX REPLACE "\\$\\(XSUBPP\\)" ${XSUBPP_SCRIPT} XSUBPP_EXECUTABLE ${XSUBPP_EXECUTABLE})
    elseif (${dir} MATCHES "^XSUBPPDEPS = ")
        string(REGEX REPLACE "^XSUBPPDEPS = (.*)" \\1 XSUBPP_DEPS ${dir})
        string(REGEX REPLACE "\\$\\(DFSEP\\)" / XSUBPP_DEPS ${XSUBPP_DEPS})
    elseif (${dir} MATCHES "^XSUBPPARGS = ")
        string(REGEX REPLACE "^XSUBPPARGS = (.*)" \\1 XSUBPP_ARGS ${dir})
        string(REGEX REPLACE "\\$\\(DFSEP\\)" / XSUBPP_ARGS ${XSUBPP_ARGS})
        separate_arguments(XSUBPP_ARGS UNIX_COMMAND "${XSUBPP_ARGS}")
    endif()
endforeach()

function(xsubpp input output)
    string(REGEX REPLACE "\\.[^.]*$" ".xs" outputxs ${output})
    add_custom_command(
        OUTPUT ${output} ${outputxs}
        COMMAND ${PERL_EXECUTABLE} ARGS ${XSUBPP_SCRIPT} ${XSUBPP_ARGS} -output ${output} ${input}
        COMMAND ${CMAKE_COMMAND} ARGS -E copy ${input} ${outputxs}
        DEPENDS ${input}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endfunction()

find_package_handle_standard_args(XSUBPP DEFAULT_MSG XSUBPP_EXECUTABLE)
