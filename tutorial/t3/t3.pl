#!/usr/local/bin/perl -w

use strict;
use warnings;
use blib;

use Qt;

sub main {
    my $window = Qt::QWidget();
    $window->resize(200, 120);

    my $quit = Qt::QPushButton("Quit", $window);
    $quit->setFont(Qt::QFont("Times", 18, Qt::QFont::Bold()));
    $quit->setGeometry(10, 40, 180, 40);
    Qt::QObject::connect($quit, SIGNAL "clicked()", Qt::qapp(), SLOT "quit()");

    $window->show();
    return Qt::appexec();
} 

main();
