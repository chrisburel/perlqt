#!/usr/local/bin/perl -w

use strict;
use warnings;
use blib;

package LCDRange;

use Qt;
use Qt::isa qw(Qt::Widget);

sub NEW {
    shift->SUPER::NEW(@_);

    my $lcd = Qt::LCDNumber(2);
    $lcd->setSegmentStyle(Qt::LCDNumber::Filled());

    my $slider = Qt::Slider(Qt::Horizontal());
    $slider->setRange(0, 99);
    $slider->setValue(0);

    this->connect($slider, SIGNAL "valueChanged(int)",
                  $lcd, SLOT "display(int)");

    my $layout = Qt::VBoxLayout;
    $layout->addWidget($lcd);
    $layout->addWidget($slider);
    this->setLayout($layout);
}

package MyWidget;

use Qt;
use Qt::isa qw(Qt::Widget);
use LCDRange;

sub NEW {
    shift->SUPER::NEW(@_);

    my $quit = Qt::PushButton("Quit");
    $quit->setFont(Qt::Font("Times", 18, Qt::Font::Bold()));
    this->connect($quit, SIGNAL "clicked()", qApp, SLOT "quit()");

    my $grid = Qt::GridLayout();

    foreach my $row ( 0..2 ) {
        foreach my $column ( 0..2 ) {
            my $lcdRange = LCDRange();
            $grid->addWidget($lcdRange, $row, $column);
        }
    }

    my $layout = Qt::VBoxLayout;
    $layout->addWidget($quit);
    $layout->addLayout($grid);
    this->setLayout($layout);
}

package main;

use Qt;
use MyWidget;

sub main {
    my $app = Qt::Application( \@ARGV );
    my $widget = MyWidget();
    $widget->show();
    return $app->exec();
} 

main();
