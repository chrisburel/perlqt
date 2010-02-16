#!/usr/local/bin/perl -w

use strict;
use warnings;
use blib;

package MyWidget;

use Qt;
use Qt::isa qw(Qt::QWidget);

sub NEW {
    shift->SUPER::NEW(@_);

    this->setFixedSize(200, 120);

    my $quit = Qt::QPushButton("Quit", this);
    $quit->setGeometry(62, 40, 75, 30);
    $quit->setFont(Qt::QFont("Times", 18, Qt::QFont::Bold()));

    this->connect($quit, SIGNAL "clicked()", Qt::qapp(), SLOT "quit()");
}

package main;

use Qt;
use MyWidget;

sub main {
    my $widget = MyWidget();
    $widget->show();
    return Qt::qapp()->exec();
} 

main();
