#!/usr/bin/perl

use strict;
use warnings;
use Qt;
use MainWindow;

sub main
{
    my $app = Qt::Application( \@ARGV );
    my $window = MainWindow();
    $window->resize(640, 480);
    $window->show();
    return $app->exec();
}

exit main();
