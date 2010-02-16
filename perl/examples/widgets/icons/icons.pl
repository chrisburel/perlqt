#!/usr/bin/perl

use strict;
use warnings;
use blib;

use Qt;
use MainWindow;

use utf8;

sub main {
    my $app = Qt::Application( \@ARGV );
    my $mainWin = MainWindow();
    $mainWin->show();
    exit $app->exec();
}

main();
