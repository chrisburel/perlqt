use 5.008006;
use ExtUtils::MakeMaker;

$CC = 'g++';

#$build = 'release';
$build = 'debug';

$QT_DIR = "/usr/local/Trolltech/Qt-4.4.0/$build";
$QT_INCLUDE = "$QT_DIR/include";
$QT_LIB = "$QT_DIR/lib";

$SMOKE_DIR = "/home/chris/src/kdebindings/$build/smoke";
$SMOKE_LIB = "$SMOKE_DIR/qt";

$CXX_FLAGS = "-Wall";
$CXX_LIBS = "-L$QT_LIB -L$SMOKE_LIB -lQtCore -lQtGui -lsmokeqt";
$CXX_INC = "-I. -I$QT_INCLUDE -I$SMOKE_DIR";
$OPTIMIZE = ( $build eq 'release' ) ? '-O2' : '-g';
$DEFINE = '-DDEBUG' if $build eq 'debug';

WriteMakefile(
    NAME              => 'Qt',
    VERSION_FROM      => 'lib/Qt.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Qt.pm', # retrieve abstract from module
       AUTHOR         => 'Chris Burel <chrisburel@gmail.com>') : ()),
    INC               => "$CXX_INC",
    LIBS              => ["$CXX_LIBS"],
    DEFINE            => $DEFINE, # e.g., '-DHAVE_SOMETHING'
    OBJECT            => '$(O_FILES)', # link all the C files too

    # C++ code:
    CC                => $CC,
    LD                => '$(CC)',
    XSOPT             => '-C++',

    # Use warnings
    CCFLAGS           => "$CXX_FLAGS",

    # Set the optimization for whichever build type
    OPTIMIZE          => $OPTIMIZE,

    # So we don't have to define LD_LIBRARY_PATH
    USE_MM_LD_RUN_PATH => 1,

);
