#!/usr/bin/perl

use strict;
use warnings;
use Qt4;

use Window;

sub main
{
    my $app = Qt4::Application(\@ARGV);

    my $window = Window();
    $window->show();

    return $app->exec();
}

exit main();
