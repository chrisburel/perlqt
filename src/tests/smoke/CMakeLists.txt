find_package(Smoke)

set(smoketestlib_dirs "        <dir>${CMAKE_CURRENT_SOURCE_DIR}/..</dir>")
configure_file(config.xml.cmake ${CMAKE_CURRENT_BINARY_DIR}/config.xml @ONLY)

add_custom_command(
    OUTPUT
        ${CMAKE_CURRENT_BINARY_DIR}/smokedata.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/x_1.cpp

    COMMAND
        ${SMOKE_GEN_BIN}
    ARGS
        -config "${CMAKE_CURRENT_BINARY_DIR}/config.xml"
        -smokeconfig "${CMAKE_CURRENT_SOURCE_DIR}/smokeconfig.xml"
        -L "${CMAKE_BINARY_DIR}"
        --
        ${CMAKE_CURRENT_SOURCE_DIR}/smoketestlib_includes.h

    DEPENDS
        ${SMOKE_GEN_BIN}
        "${CMAKE_CURRENT_BINARY_DIR}/config.xml"
        "${CMAKE_CURRENT_SOURCE_DIR}/smokeconfig.xml"

    WORKING_DIRECTORY
        ${CMAKE_CURRENT_BINARY_DIR}
)

set(smoketestlib_LIB_SRCS
    ${CMAKE_CURRENT_BINARY_DIR}/smokedata.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/x_1.cpp
)

include_directories(${SMOKE_INCLUDE_DIR})
include_directories(
    ${CMAKE_SOURCE_DIR}/src/tests/
    ${CMAKE_SOURCE_DIR}/src/tests/smoke
)
add_library(smokesmoketestlib SHARED ${smoketestlib_LIB_SRCS})
target_link_libraries(smokesmoketestlib ${SMOKE_BASE_LIBRARY} smoketestlib)
