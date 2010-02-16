#!/usr/bin/perl

use strict;
use warnings;

use Qt;

use AnalogClock;

sub main {
    my $app = Qt::Application( \@ARGV );
    my $clock = AnalogClock();
    $clock->show();
    exit $app->exec();
}

main();
