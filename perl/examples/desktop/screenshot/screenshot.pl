#!/usr/bin/perl

use strict;
use warnings;
use Qt;
use Screenshot;

sub main
{
    my $app = Qt::Application( \@ARGV );
    my $screenshot = Screenshot();
    $screenshot->show();
    return $app->exec();
}

exit main();
