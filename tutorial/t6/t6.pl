#!/usr/local/bin/perl -w

use strict;
use warnings;
use blib;

package LCDRange;

use Qt;
use Qt::isa qw(Qt::QWidget);

sub NEW {
    shift->SUPER::NEW(@_);

    my $lcd = Qt::QLCDNumber(2);
    $lcd->setSegmentStyle(Qt::QLCDNumber::Filled());

    my $slider = Qt::QSlider(Qt::Qt::Horizontal());
    $slider->setRange(0, 99);
    $slider->setValue(0);

    this->connect($slider, SIGNAL "valueChanged(int)",
                  $lcd, SLOT "display(int)");

    my $layout = Qt::QVBoxLayout;
    $layout->addWidget($lcd);
    $layout->addWidget($slider);
    this->setLayout($layout);
}

package MyWidget;

use Qt;
use Qt::isa qw(Qt::QWidget);
use LCDRange;

sub NEW {
    shift->SUPER::NEW(@_);

    my $quit = Qt::QPushButton("Quit");
    $quit->setFont(Qt::QFont("Times", 18, Qt::QFont::Bold()));
    this->connect($quit, SIGNAL "clicked()", Qt::qapp(), SLOT "quit()");

    my $grid = Qt::QGridLayout();

    foreach my $row ( 0..2 ) {
        foreach my $column ( 0..2 ) {
            my $lcdRange = LCDRange();
            $grid->addWidget($lcdRange, $row, $column);
        }
    }

    my $layout = Qt::QVBoxLayout;
    $layout->addWidget($quit);
    $layout->addLayout($grid);
    this->setLayout($layout);
}

package main;

use Qt;
use MyWidget;

sub main {
    my $widget = MyWidget();
    $widget->show();
    return Qt::appexec();
} 

main();
