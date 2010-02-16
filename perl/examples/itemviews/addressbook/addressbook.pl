#!/usr/bin/perl

use strict;
use warnings;

use Qt;
use MainWindow;

sub main {
    my $app = Qt::Application( \@ARGV );
    my $mw = MainWindow();
    $mw->show();
    exit $app->exec();
}

main();
