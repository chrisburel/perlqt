use strict;
use warnings;
use PerlQt5::QtCore;
use Test::More tests => 6;

our $connected = 0;
our $name;

sub mySub {
    my ($newName) = @_;
    if ($connected) {
        ok('Slot called');
        is(scalar @_, 1, 'Argument count in non-qobject slot');
        is($newName, $name, 'Argument value in non-qobject slot');
    }
    else {
        fail('Slot called when disconnected');
    }
}

my $app = PerlQt5::QtCore::QCoreApplication->new(scalar @ARGV, \@ARGV);
my $mo = $app->metaObject();
my $signal = bless {
    instance => $app,
    name => 'objectNameChanged',
    signalIndex => $mo->indexOfSignal('objectNameChanged(QString)'),
}, 'PerlQt5::QtCore::Signal';

$signal->connect(\&mySub);
$connected = 1;
$name = 'yo';
$app->setObjectName($name);

$signal->disconnect(\&mySub);
$connected = 0;
$app->setObjectName($name);

$signal->connect(\&mySub);
$connected = 1;
$name = 'new name';
$app->setObjectName($name);
