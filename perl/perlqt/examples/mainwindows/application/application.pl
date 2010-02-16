#!/usr/bin/perl -w

use strict;

use Qt4;
use MainWindow;

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $mainWin = MainWindow();
    $mainWin->show();
    exit $app->exec();
}

main();
