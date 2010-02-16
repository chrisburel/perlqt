#!/usr/bin/perl

use strict;
use warnings;
use blib;

use Qt;
use DigitalClock;

sub main {
    my $app = Qt::Application( \@ARGV );
    my $clock = DigitalClock();
    $clock->show();
    exit $app->exec();
}

main();
