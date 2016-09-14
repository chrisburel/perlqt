use Test::More tests => 3;

use strict;
use warnings;

use PerlSmokeTest;

my $app = PerlSmokeTest::QApplication->new();
my $app2 = $app->instance();

is($app2, $app);
is(ref $app, 'PerlSmokeTest::QApplication');
is(ref $app2, 'PerlSmokeTest::QApplication');
