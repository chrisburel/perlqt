#####################################################################
# PerlQt4

OPTION(ENABLE_PERLQT4 "build PerlQt4" ON)
OPTION(ENABLE_PERLQTTEST4 "build PerlQtTest4" ON)

FIND_PACKAGE ( Perl )
FIND_PACKAGE ( PerlLibs )

include (FindPerlMore)
SET(CUSTOM_PERL_SITE_ARCH_DIR ${PERL_SITE_ARCH_DIR} CACHE DIR "Custom installation directory for perl binary extension" )

set(PERLQT4_ENABLED "no")
set(PERLQTTEST4_ENABLED "no")

if(ENABLE_PERLQT4)
    add_subdirectory( perlqt )
    set(PERLQT4_ENABLED "yes")
endif(ENABLE_PERLQT4)
if(ENABLE_PERLQTTEST4)
    add_subdirectory( qttest )
    set(PERLQTTEST4_ENABLED "yes")
endif(ENABLE_PERLQTTEST4)

message(STATUS "Build PerlQt4... " ${PERLQT4_ENABLED})
message(STATUS "Build PerlQtTest4... " ${PERLQTTEST4_ENABLED})
