#!/usr/bin/perl

use strict;
use warnings;
use blib;

use Qt;
use Calculator;

sub main {
    my $app = Qt::Application( \@ARGV );
    my $calc = Calculator();
    $calc->show();
    exit $app->exec();
}

main();
