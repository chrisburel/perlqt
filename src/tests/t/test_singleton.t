use Test::More tests => 16;

use strict;
use warnings;

use B qw(svref_2object);
use PerlSmokeTest;
use SmokePerl;

my $app = PerlSmokeTest::QApplication->new();
is(svref_2object($app)->REFCNT, 1);

my $app2 = $app->instance();
is(svref_2object($app)->REFCNT, 2);
is(svref_2object($app2)->REFCNT, 2);

is($app2, $app);
is(ref $app, 'PerlSmokeTest::QApplication');
is(ref $app2, 'PerlSmokeTest::QApplication');

my $app1ptr = SmokePerl::getCppPointer($app);
my $app2ptr = SmokePerl::getCppPointer($app2);
ok(defined $app1ptr);
ok(defined $app2ptr);
is($app1ptr, $app2ptr);

undef $app;
is(svref_2object($app2)->REFCNT, 1);

my $newRef = SmokePerl::getInstance($app1ptr);
is($app2, $newRef);
is(svref_2object($app2)->REFCNT, 2);
is(svref_2object($newRef)->REFCNT, 2);

undef $app2;
is(svref_2object($newRef)->REFCNT, 1);
undef $newRef;
ok(!defined SmokePerl::getInstance($app1ptr));
ok(!defined PerlSmokeTest::QApplication->instance());
