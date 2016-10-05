use strict;
use warnings;
use PerlQt5::QtCore;
use Test::More tests => 4;

package MyApp;
use base qw(PerlQt5::QtCore::QCoreApplication);

sub mySlot : Slot(int, int) {
}

sub mySlot2 : Slot(const char*, int) Slot(const QString&, int) {
}

package main;
my $baseMetaObject = PerlQt5::QtCore::QCoreApplication->staticMetaObject();
my $mo = MyApp->staticMetaObject();

is($baseMetaObject->methodCount(), $mo->methodCount() - 3);
is($mo->method($mo->methodCount()-3)->methodSignature()->constData(), 'mySlot(int,int)');
is($mo->method($mo->methodCount()-2)->methodSignature()->constData(), 'mySlot2(const char*,int)');
is($mo->method($mo->methodCount()-1)->methodSignature()->constData(), 'mySlot2(QString,int)');
