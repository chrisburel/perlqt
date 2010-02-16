#!/usr/bin/perl

use strict;
use warnings;
use blib;

use Qt;
use SortingBox;

sub main {
    my $app = Qt::Application( \@ARGV );
    srand(Qt::Time(0,0,0)->secsTo(Qt::Time::currentTime()));
    my $sortingBox = SortingBox();
    $sortingBox->show();
    return $app->exec();
}

exit main();
