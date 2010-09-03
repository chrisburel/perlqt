#!/usr/bin/perl

use strict;
use warnings;

use QtCore4;
use QtGui4;
use MainWindow;

sub main
{
    my $app = Qt::Application(\@ARGV);
    my $mainWindow = MainWindow();
    $mainWindow->setGeometry(100, 100, 800, 500);
    $mainWindow->show();

    return $app->exec();
}

exit main();
