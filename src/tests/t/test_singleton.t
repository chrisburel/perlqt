use Test::More tests => 16;

use strict;
use warnings;

use Devel::Peek qw(SvREFCNT);
use PerlSmokeTest;
use SmokePerl;

my $app = PerlSmokeTest::QApplication->new();
is(SvREFCNT(%$app), 1);

my $app2 = $app->instance();
is(SvREFCNT(%$app), 2);
is(SvREFCNT(%$app2), 2);

is($app2, $app);
is(ref $app, 'PerlSmokeTest::QApplication');
is(ref $app2, 'PerlSmokeTest::QApplication');

my $app1ptr = SmokePerl::getCppPointer($app);
my $app2ptr = SmokePerl::getCppPointer($app2);
ok(defined $app1ptr);
ok(defined $app2ptr);
is($app1ptr, $app2ptr);

undef $app;
is(SvREFCNT(%$app2), 1);

my $newRef = SmokePerl::getInstance($app1ptr);
is($app2, $newRef);
is(SvREFCNT(%$app2), 2);
is(SvREFCNT(%$newRef), 2);

undef $app2;
is(SvREFCNT(%$newRef), 1);
undef $newRef;
ok(!defined SmokePerl::getInstance($app1ptr));
ok(!defined PerlSmokeTest::QApplication->instance());
