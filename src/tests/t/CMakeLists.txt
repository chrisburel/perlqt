enable_testing()
set(USE_BUILD_DIR_FOR_TESTS ON)

file(GLOB testFiles *.t)
foreach(testFile ${testFiles})
    string(REGEX REPLACE "\\.t$" "" testName "${testFile}")
    macro_prove(${testName} ${testFile})
endforeach()
