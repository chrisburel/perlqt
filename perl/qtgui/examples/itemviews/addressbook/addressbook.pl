#!/usr/bin/perl

use strict;
use warnings;

use Qt4;
use MainWindow;

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $mw = MainWindow();
    $mw->show();
    exit $app->exec();
}

main();
