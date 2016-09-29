use strict;
use warnings;

use Test::More tests => 1;

use PerlSmokeTest;

package Application;

use base qw(PerlSmokeTest::QApplication);

sub new {
    my ($class) = @_;
    return $class->SUPER::new();
}

package main;

sub main {
    new_ok('Application');
}

main();
