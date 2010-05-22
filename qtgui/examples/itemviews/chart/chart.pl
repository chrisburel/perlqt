#!/usr/bin/perl

use strict;
use warnings;

use QtCore4;
use QtGui4;
#use Qt::debug qw(all);
use MainWindow;

sub main {
    my $app = Qt::Application( \@ARGV );
    my $window = MainWindow();
    $window->show();
    exit $app->exec();
}

main();
