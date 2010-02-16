#!/usr/bin/perl

use strict;
use warnings;

use Qt4;
use Calculator;

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $calc = Calculator();
    $calc->show();
    exit $app->exec();
}

main();
