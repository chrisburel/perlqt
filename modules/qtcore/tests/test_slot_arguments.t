use strict;
use warnings;
use PerlQt5::QtCore qw(SIGNAL SLOT);
use Test::More tests => 8;

package MyObject;
use base qw(PerlQt5::QtCore::QObject);
use Test::More;

sub mySub : Slot(int) {
    my ($self, $id) = @_;
    ok(1, 'Slot called');
    isa_ok($self, 'MyObject');
    is(scalar @_, 2, 'Slot argument count');
    is($id, $main::appId, 'Slot argument value');
}

package main;
my $app = PerlQt5::QtCore::QCoreApplication->new(\@ARGV);
my $mapper = PerlQt5::QtCore::QSignalMapper->new();
my $obj = MyObject->new();
our $appId = 1;

$mapper->connect(
    $app, SIGNAL 'applicationNameChanged()',
    $mapper, SLOT 'map()'
);
$mapper->setMapping($app, $appId);

$obj->connect(
    $mapper, SIGNAL 'mapped(int)',
    $obj, SLOT 'mySub(int)'
);

$app->setApplicationName('PerlQt5 connection test');

$appId = 42;
$mapper->setMapping($app, $appId);
$app->setApplicationName('PerlQt5 connection test 2');
