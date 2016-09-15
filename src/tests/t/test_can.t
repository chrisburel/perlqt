use Test::More tests => 6;

use strict;
use warnings;

use PerlSmokeTest;

my $ctor = PerlSmokeTest::QApplication->can('new');
ok(defined $ctor);

my $app = $ctor->('PerlSmokeTest::QApplication');
ok(defined $app);
is(ref $app, 'PerlSmokeTest::QApplication');

my $instanceSub = $app->can('instance');
ok(defined $instanceSub);

my $app2 = $instanceSub->($app);
is($app, $app2);

my $cant = $app->can('nonexistantMethod');
ok(!defined $cant);
