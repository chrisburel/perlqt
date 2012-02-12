#!/usr/bin/perl

use strict;
use warnings;

use QtCore4;
use QtGui4;
use Phonon;

use MainWindow;

sub main {
    my $app = Qt::Application(\@ARGV);
    $app->setApplicationName('Music Player');
    $app->setQuitOnLastWindowClosed(1);

    my $window = MainWindow();
    $window->show();

    return $app->exec();
}

exit main();
