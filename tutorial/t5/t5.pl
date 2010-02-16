#!/usr/local/bin/perl -w

use strict;
use warnings;
use blib;

package MyWidget;

use Qt;
use Qt::isa qw(Qt::QWidget);

sub NEW {
    shift->SUPER::NEW(@_);

    my $quit = Qt::QPushButton("Quit");
    $quit->setFont(Qt::QFont("Times", 18, Qt::QFont::Bold()));

    my $lcd = Qt::QLCDNumber(2);
    $lcd->setSegmentStyle(Qt::QLCDNumber::Filled());

    my $slider = Qt::QSlider(Qt::Qt::Horizontal());
    $slider->setRange(0, 99);
    $slider->setValue(0);

    this->connect($quit, SIGNAL "clicked()", Qt::qapp(), SLOT "quit()");
    this->connect($slider, SIGNAL "valueChanged(int)",
                  $lcd, SLOT "display(int)");

    my $layout = Qt::QVBoxLayout;
    $layout->addWidget($quit);
    $layout->addWidget($lcd);
    $layout->addWidget($slider);
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
