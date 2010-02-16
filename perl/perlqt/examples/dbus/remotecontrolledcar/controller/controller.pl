#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use Controller;

sub main
{
    my $app = Qt4::Application(\@ARGV);
    my $controller = Controller();
    $controller->show();
    return $app->exec();
}

exit main();
