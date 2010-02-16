#!/usr/bin/perl

use strict;
use warnings;

use Qt4;
use DigitalClock;

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $clock = DigitalClock();
    $clock->show();
    exit $app->exec();
}

main();
