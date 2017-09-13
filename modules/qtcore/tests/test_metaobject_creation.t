use strict;
use warnings;
use PerlQt5::QtCore;
use Test::More tests => 8;

package MyApp;
use base qw(PerlQt5::QtCore::QCoreApplication);

package main;
my $app = MyApp->new(scalar @ARGV, \@ARGV);
my $mo = $app->metaObject();
is($mo->className(), 'MyApp');
is($mo->superClass()->className(), 'QCoreApplication');
is($mo->superClass()->superClass()->className(), 'QObject');

$mo = PerlQt5::QtCore::QCoreApplication->staticMetaObject();
is($mo->className(), 'QCoreApplication');
is($mo->superClass()->className(), 'QObject');

$mo = MyApp->staticMetaObject();
is($mo->className(), 'MyApp');
is($mo->superClass()->className(), 'QCoreApplication');
is($mo->superClass()->superClass()->className(), 'QObject');
