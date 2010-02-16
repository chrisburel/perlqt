#!/usr/local/bin/perl -w

use strict;
use blib;

use Qt;
use MainWindow;

sub main {
    #Q_INIT_RESOURCE(application);

    my $mainWin = MainWindow();
    $mainWin->show();
    exit Qt::qapp()->exec();
}

main();
