use strict;
use warnings;
use PerlQt5::QtCore;
use Test::More tests => 7;

our $connected = 0;
our $name;

sub mySub {
    my ($newName) = @_;
    if ($connected) {
        ok(1, 'Slot called');
        is(scalar @_, 1, 'Argument count in non-qobject slot');
        is($newName, $name, 'Argument value in non-qobject slot');
    }
    else {
        fail('Slot called when disconnected');
    }
}

my $app = PerlQt5::QtCore::QCoreApplication->new(\@ARGV);
my $signal = $app->can('objectNameChanged');
isa_ok($signal, 'PerlQt5::QtCore::Signal');

$signal->connect(\&mySub);
$connected = 1;
$name = 'yo';
$app->setObjectName($name);

$signal->disconnect(\&mySub);
$connected = 0;
$app->setObjectName('foo');

$signal->connect(\&mySub);
$connected = 1;
$name = 'new name';
$app->setObjectName($name);
