use strict;
use warnings;
use PerlQt5::QtCore;
use Test::More tests => 3;

package MyObject;
use Test::More;
use base qw(PerlQt5::QtCore::QObject);

sub mySlot : Slot() {
    print "mySlot\n";
    ok('Slot called');
}

package MyObjectSubclass;
use Test::More;
use base qw(MyObject);

sub mySlotSubclass : Slot() {
    print "mySlotSubclass\n";
    ok('Subclass slot called');
}

package main;
my $app = PerlQt5::QtCore::QCoreApplication->new(scalar @ARGV, \@ARGV);
my $obj = MyObject->new();
my $objSubclass = MyObjectSubclass->new();
PerlQt5::QtCore::QTimer->singleShot(0, $obj, "1mySlot()");
PerlQt5::QtCore::QTimer->singleShot(0, $objSubclass, "1mySlot()");
PerlQt5::QtCore::QTimer->singleShot(0, $objSubclass, "1mySlotSubclass()");
$app->processEvents();
