#!/usr/bin/perl

use strict;
use warnings;

use Qt4;
use ShapedClock;

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $clock = ShapedClock();
    $clock->show();
    return $app->exec();
}

exit main();
