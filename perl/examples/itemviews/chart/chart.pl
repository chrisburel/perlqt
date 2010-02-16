#!/usr/bin/perl

use strict;
use warnings;
use blib;

use Qt;
#use Qt::debug qw(all);
use MainWindow;

sub main {
    my $app = Qt::Application( \@ARGV );
    my $window = MainWindow();
    $window->show();
    exit $app->exec();
}

main();
