#!/usr/bin/perl

# Build.PL
#  Script to build and install this distribution
#
# $Id: Build.PL 7048 2009-05-12 18:18:13Z FREQUENCY@cpan.org $
#
# Copyright (C) 2009 Jonathan Yu <frequency@cpan.org>. All rights reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version. See the LICENSE file, included in this distribution,
# for full details.

use strict;
use warnings;

use Getopt::Long;
use Module::Build;

use lib 'inc';
use QtBuilder;

my( $userSmokeDir, $userSmokeIncDir, $userSmokeLibDir,
    $userQtDir,    $userQtIncDir,    $userQtLibDir );
my @flags;
my @libs;

GetOptions(
    '--with-smoke-dir:s' => \$userSmokeDir,
    '--with-smoke-inc-dir:s' => \$userSmokeIncDir,
    '--with-smoke-lib-dir:s' => \$userSmokeLibDir,
    '--with-qt-dir:s' => \$userQtDir,
    '--with-qt-inc-dir:s' => \$userQtIncDir,
    '--with-qt-lib-dir:s' => \$userQtLibDir,
    '--build-debug' => sub {push(@flags, '-DDEBUG')},
);

if( $userSmokeDir ) {
    $userSmokeIncDir = "$userSmokeDir/include" if !$userSmokeIncDir;
    $userSmokeLibDir = "$userSmokeDir/lib" if !$userSmokeLibDir;
}
if( $userQtDir ) {
    $userQtIncDir = "$userQtDir/include" if !$userQtIncDir;
    $userQtLibDir = "$userQtDir/lib" if !$userQtLibDir;
}

# The bindings should be compiled with the flags for libsmokeqt and qt4
push(@flags,
  '-std=gnu++98',
  '-Wall',
  '-xc++',
  '-I.',
);

# If the user specified a specific path for Qt or Smoke, make sure that's in
# the include path
foreach my $path ( $userSmokeIncDir, $userQtIncDir ) {
    push(@flags, "-I$path") if $path;
}

# If the user specified a specific path for Qt or Smoke, make sure that's in
# the lib path
foreach my $path ( $userSmokeLibDir, $userQtLibDir ) {
    push(@libs, "-L$path") if $path;
}

# Find QtGui using pkg-config
# QtGui depends on QtCore, so both libraries will be loaded
my $flags = `pkg-config --cflags QtGui QtCore QtXml`;
if (defined($flags) && length($flags)) {
  push(@flags, split(' ', $flags));
  # If pkg-config got the cflags, we can assume libs will work too
  push(@libs, split(' ', `pkg-config --libs QtGui QtCore QtXml`));
}
else {
  # If pkg-config couldn't find it, try qmake
  #$flags = `qmake`;
  #if (defined($flags) && length($flags)) {
  #}
  #else {
    print STDERR 'Could not find SmokeQt4, QtCore and QtGui automatically; ' .
      "using some defaults.\n";
    print STDERR "To override this behaviour, see INSTALLING\n";

    # Some sane defaults
    push(@flags,
      '-DQT_SHARED',
      '-I/usr/include/qt4',
      '-I/usr/include/qt4/QtCore',
      '-I/usr/include/qt4/QtGui',
    );
    push(@libs,
      '-lQtGui',
      '-lQtCore',
    );
  #}
}

# Try to load Alien::QtSmoke to find the location of the smoke library
eval{ require Alien::QtSmoke };
if ( !$@ ) {
    # load successful
    push(@flags, '-I' . Alien::QtSmoke->include());

    # Add an rpath to the .so to make sure it can find libsmokeqt after install
    push(@libs, '-Wl,--rpath,' . Alien::QtSmoke->lib());

    push(@libs, '-L' . Alien::QtSmoke->lib());
    push(@libs, '-lsmokeqt');
}
else {
    warn "Module Alien::QtSmoke not found.  We'll try to use the system" .
    " installed libsmokeqt (if it exists).";
    push(@libs, '-lsmokeqt');
}

my $builder = QtBuilder->new(
  module_name           => 'Qt4',
  license               => 'gpl',
  dist_author           => 'Chris Burel <chrisburel@gmail.com>',
  dist_version_from     => 'lib/Qt4.pm',
  dynamic_config        => 1,
  create_readme         => 1,
  recursive_test_files  => 1,
  sign                  => 1,
  create_packlist       => 1,

  # Maintain compatibility with ExtUtils::MakeMaker installations
  create_makefile_pl    => 'passthrough',

  # Location of our special C and XS source files
  c_source => 'src',
  xs_files => {
    'src/Qt4.xs' => 'lib/Qt4.xs'
  },

  extra_compiler_flags  => \@flags,
  extra_linker_flags    => \@libs,

  requires => {
    'perl'                  => 5.006,

    # Pragmatic and special modules
    'Carp'                  => 1.04,
    'version'               => 0,
    'warnings'              => 0,
    'strict'                => 0,
  },
  build_requires => {
    # For the XS build process
    'ExtUtils::CBuilder'    => 0,
    'ExtUtils::ParseXS'     => 0,
  },
  recommends => {
    'Alien::QtSmoke'        => '4.3.3',
  },
  conflicts => {
  },

  add_to_cleanup => [ 'Qt-*' ],
  script_files => [],

  meta_merge => {
    resources => {
      # Custom resources (must begin with an uppercase letter)
      Ratings      => 'http://cpanratings.perl.org/d/Qt',

      # Official keys (homepage, license, bugtracker)
      repository   => 'http://perlqt4.googlecode.com/svn/trunk/PerlQt4/perl/',
      bugtracker   => 'http://rt.cpan.org/NoAuth/Bugs.html?Dist=Qt',
      license      => 'http://www.opensource.org/licenses/gpl-2.0.php',
    },
  },
);

$builder->create_build_script();
