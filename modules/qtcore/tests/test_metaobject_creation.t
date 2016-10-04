use strict;
use warnings;
use PerlQt5::QtCore;
use Test::More tests => 3;

package MyApp;
use base qw(PerlQt5::QtCore::QCoreApplication);

package main;
my $app = MyApp->new($#ARGV, \@ARGV);
my $mo = $app->metaObject();
is($mo->className(), 'MyApp');
is($mo->superClass()->className(), 'QCoreApplication');
is($mo->superClass()->superClass()->className(), 'QObject');
