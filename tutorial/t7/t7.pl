#!/usr/local/bin/perl -w

use strict;
use warnings;
use blib;

package MyWidget;

use Qt;
use Qt::isa qw(Qt::QWidget);
use LCDRange;

my @widgets;

sub NEW {
    shift->SUPER::NEW(@_);

    my $quit = Qt::QPushButton("Quit");
    $quit->setFont(Qt::QFont("Times", 18, Qt::QFont::Bold()));

    this->connect($quit, SIGNAL "clicked()", Qt::qapp(), SLOT "quit()");

    my $grid = Qt::QGridLayout();
    my $previousRange;


    foreach my $row ( 0..2 ) {
        foreach my $column ( 0..2 ) {
            my $lcdRange = LCDRange();
            $grid->addWidget($lcdRange, $row, $column);
            if ($previousRange) {
                this->connect($lcdRange, SIGNAL "valueChanged(int)",
                              $previousRange, SLOT "setValue(int)");
            }
            $previousRange = $lcdRange;
            push @widgets, $lcdRange;
        }
    }

    my $layout = Qt::QVBoxLayout;
    $layout->addWidget($quit);
    $layout->addLayout($grid);
    this->setLayout($layout);
}

1;

package main;

use Qt;
use MyWidget;

sub main {
    my $widget = MyWidget();
    $widget->show();
    return Qt::appexec();
} 

main();
