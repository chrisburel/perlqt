#!/usr/local/bin/perl -w

use lib '/home/chris/src/qt/4/PerlQt/blib/lib';
use lib '/home/chris/src/qt/4/PerlQt/blib/arch';

use strict;
use warnings;
use Qt;

sub main {
    my $quit = Qt::QPushButton("Quit");
    $quit->resize(150, 30);
    $quit->setFont(Qt::QFont("Times", 18, Qt::QFont::Bold()));

    Qt::QObject::connect( $quit, SIGNAL "clicked()",
                          Qt::qapp(), SLOT "quit()" );

    $quit->show();

    return Qt::appexec();
}

main();
