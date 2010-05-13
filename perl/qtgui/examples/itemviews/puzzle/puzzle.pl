#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use MainWindow;

sub main
{
    my $app = Qt4::Application( \@ARGV );
    my $window = MainWindow();
    $window->openImage('images/example.jpg');
    $window->show();
    return $app->exec();
}

exit main();
