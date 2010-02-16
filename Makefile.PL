use 5.008006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

$CC = 'g++';

$QT_DIR = '/usr/local/Trolltech/Qt-4.4.0';
$QT_INCLUDE = "$QT_DIR/include";
$QT_LIB = "$QT_DIR/lib";

#$SMOKE_DIR = '/pts/testPipe/share/Qt4/def/dat/kdebindings/smoke';
$SMOKE_DIR = '/home/chris/src/kdebindings/smoke';
$SMOKE_LIB = "$SMOKE_DIR/qt";

$CXX_FLAGS = "-g -Wall";
$CXX_LIBS = "-L$QT_LIB -L$SMOKE_LIB -lQtCore -lQtGui -lsmokeqt";
$CXX_INC = "-I. -I$QT_INCLUDE -I$SMOKE_DIR";

WriteMakefile(
    NAME              => 'Qt',
    VERSION_FROM      => 'lib/Qt.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Qt.pm', # retrieve abstract from module
       AUTHOR         => 'Chris Burel <chris@localdomain>') : ()),
    LIBS              => ["$CXX_LIBS"], # e.g., '-lm'
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    INC               => "$CXX_INC",
    OBJECT            => '$(O_FILES)', # link all the C files too

    # To get C++ code to work:
    CC                => $CC,
    LD                => '$(CC)',
    XSOPT             => '-C++',

    USE_MM_LD_RUN_PATH => 1,
    # Debugging
    CCFLAGS           => "$CXX_FLAGS",
);
