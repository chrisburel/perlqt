use strict;
use warnings;

use Test::More tests => 1;

use PerlSmokeTest;

my $app = PerlSmokeTest::QApplication->new();

my $fakeApp = bless {}, 'PerlSmokeTest::QApplication';
ok(!defined $fakeApp->instance());

eval { $app->notAMethod() } and ok($@ eq 'Unable to resolve method.');
