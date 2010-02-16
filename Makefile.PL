use 5.008006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

$CC = 'g++';
#$pathToSrc = '/usr/scratch/cburel';
$pathToSrc = '/home/chris/';
$qtincludePath = '/usr/local/Trolltech/Qt-4.4.0/include';
$qtsmokePath = '/home/chris/src/kdebindings/smoke/qt';
$smokePath = '/home/chris/src/kdebindings/smoke';

WriteMakefile(
    NAME              => 'QtSimple',
    VERSION_FROM      => 'lib/QtSimple.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/QtSimple.pm', # retrieve abstract from module
       AUTHOR         => 'Chris Burel <chris@localdomain>') : ()),
    LIBS              => ['-L/usr/local/Trolltech/Qt-4.4.0/lib -lQtCore -lQtGui'], # e.g., '-lm'
    DEFINE            => '', # e.g., '-DHAVE_SOMETHING'
    INC               => "-I. -I$qtincludePath -I$smokePath",
	# Un-comment this if you add C files to link with later:
    OBJECT            => '$(O_FILES)', # link all the C files too
    LDFROM            => '$(O_FILES)' . " $qtsmokePath/libsmokeqt.so.2",

    # To get C++ code to work:
    CC                => $CC,
    LD                => '$(CC)',
    XSOPT             => '-C++',

    # Debugging
    CCFLAGS           => '-g',
);
