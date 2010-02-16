#!/usr/bin/perl

use strict;
use warnings;

use Qt4;
use MainWindow;

use utf8;

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $mainWin = MainWindow();
    $mainWin->show();
    exit $app->exec();
}

main();
