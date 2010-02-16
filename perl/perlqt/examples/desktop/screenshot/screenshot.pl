#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use Screenshot;

sub main
{
    my $app = Qt4::Application( \@ARGV );
    my $screenshot = Screenshot();
    $screenshot->show();
    return $app->exec();
}

exit main();
