#!/usr/bin/perl

use strict;
use warnings;

use Qt4;
use SortingBox;

sub main {
    my $app = Qt4::Application( \@ARGV );
    srand(Qt4::Time(0,0,0)->secsTo(Qt4::Time::currentTime()));
    my $sortingBox = SortingBox();
    $sortingBox->show();
    return $app->exec();
}

exit main();
