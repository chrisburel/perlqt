#!/usr/local/bin/perl -w

use lib '/home/chris/src/qt/4/PerlQt/blib/lib';
use lib '/home/chris/src/qt/4/PerlQt/blib/arch';

use strict;
use warnings;
use Qt;

sub main {
    my $quit = Qt::QPushButton("Quit");
    $quit->resize(75, 30);
    $quit->setFont(Qt::QFont("Times", 18));

    $quit->show();
    return Qt::appexec();
}

main();
