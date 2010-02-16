#!/usr/bin/perl

use strict;
use warnings;

use Qt4;

use AnalogClock;

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $clock = AnalogClock();
    $clock->show();
    exit $app->exec();
}

main();
