#!/usr/bin/perl

use strict;
use warnings;

use Qt4;
use CalculatorForm;

sub main {
    my $app = Qt4::Application(\@ARGV);
    my $calculator = CalculatorForm();
    $calculator->show();
    exit $app->exec();
}

main();
