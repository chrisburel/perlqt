#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use MainWindow;

sub main
{
    my $app = Qt4::Application( \@ARGV );
    my $mainWin = MainWindow();
    $mainWin->show();
    return $app->exec();
}

exit main();
