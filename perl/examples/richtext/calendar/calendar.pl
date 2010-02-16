#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use MainWindow;

sub main
{
    my $app = Qt4::Application(\@ARGV);
    my $window = MainWindow();
    $window->resize(640, 256);
    $window->show();
    return $app->exec();
}

exit main();
