#!/usr/bin/perl

use strict;
use warnings;
use Qt;
use MainWindow;

sub main
{
    my $app = Qt::Application( \@ARGV );
    my $window = MainWindow();
    $window->openImage('images/example.jpg');
    $window->show();
    return $app->exec();
}

exit main();
