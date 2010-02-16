#!/usr/bin/perl

use strict;
use warnings;
use Qt;
use MainWindow;

sub main
{
    my $app = Qt::Application( \@ARGV );
    my $mainWin = MainWindow();
    $mainWin->show();
    return $app->exec();
}

exit main();
