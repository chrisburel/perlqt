#!/usr/bin/perl

use strict;
use warnings;

use Qt;
use CalculatorForm;

sub main {
    my $app = Qt::Application(\@ARGV);
    my $calculator = CalculatorForm();
    $calculator->show();
    exit $app->exec();
}

main();
