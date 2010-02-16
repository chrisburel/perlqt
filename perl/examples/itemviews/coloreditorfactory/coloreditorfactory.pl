#!/usr/bin/perl

use strict;
use warnings;
use Qt;
use Window;

sub main
{
    my $app = Qt::Application( \@ARGV );

    my $window = Window();
    $window->show();

    return $app->exec();
}

exit main();
