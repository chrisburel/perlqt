option(ENABLE_PERLQT "build PerlQt" ON)

set(PERLQT_ENABLED "no")
if(ENABLE_PERLQT)
    set(PERLQT_ENABLED "yes")
endif(ENABLE_PERLQT)

if(PERLQT_ENABLED)
    include (FindPerlMore)

    SET(CUSTOM_PERL_SITE_ARCH_DIR ${PERL_SITE_ARCH_DIR} CACHE DIR "Custom installation directory for perl binary extension" )

    add_subdirectory(lib)
    add_subdirectory(src)
    add_subdirectory(tools)
    add_subdirectory(t)

endif(PERLQT_ENABLED)

message(STATUS "Build PerlQt... " ${PERLQT_ENABLED})
