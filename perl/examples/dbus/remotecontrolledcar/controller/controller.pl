#!/usr/bin/perl

use strict;
use warnings;
use Qt;
use Controller;

sub main
{
    my $app = Qt::Application(\@ARGV);
    my $controller = Controller();
    $controller->show();
    return $app->exec();
}

exit main();
