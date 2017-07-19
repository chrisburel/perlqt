enable_testing()

file(GLOB testFiles *.t)
list(SORT testFiles)
foreach(testFile ${testFiles})
    get_filename_component(testName "${testFile}" NAME_WE)
    macro_prove(${testName} ${testFile})
endforeach()
