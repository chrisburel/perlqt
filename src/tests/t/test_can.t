use Test::More tests => 13;

use strict;
use warnings;

use PerlSmokeTest;

my $ctor = PerlSmokeTest::QApplication->can('new');
ok(defined $ctor);

my $app = $ctor->('PerlSmokeTest::QApplication');
ok(defined $app);
isa_ok($app, 'PerlSmokeTest::QApplication');

my $instanceSub = $app->can('instance');
ok(defined $instanceSub);

my $app2 = $instanceSub->($app);
is($app, $app2);

my $cant = $app->can('nonexistantMethod');
ok(!defined $cant);

package Application;

use base qw(PerlSmokeTest::QApplication);

sub new {
    my ($class) = @_;
    my $self = $class->SUPER::new();
    $self->{callCount} += 1;
    return $self;
}

package main;

$ctor = Application->can('new');
ok(defined $ctor);

$app = $ctor->('Application');
isa_ok($app, 'Application');
is($app->{callCount}, 1);

$instanceSub = $app->can('instance');
ok(defined $instanceSub);

$app2 = $instanceSub->($app);
is($app, $app2);

my $fakeApp = bless {}, 'Application';
ok(!defined $fakeApp->can('new'));

my $one = 1;
$fakeApp = bless \$one, 'Application';
ok(!defined $fakeApp->can('new'));
