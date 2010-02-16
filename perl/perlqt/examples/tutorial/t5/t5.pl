#!/usr/bin/perl -w

use strict;
use warnings;

package MyWidget;

use Qt4;
use Qt4::isa qw(Qt4::Widget);

sub NEW {
    shift->SUPER::NEW(@_);

    my $quit = Qt4::PushButton("Quit");
    $quit->setFont(Qt4::Font("Times", 18, Qt4::Font::Bold()));

    my $lcd = Qt4::LCDNumber(2);
    $lcd->setSegmentStyle(Qt4::LCDNumber::Filled());

    my $slider = Qt4::Slider(Qt4::Horizontal());
    $slider->setRange(0, 99);
    $slider->setValue(0);

    this->connect($quit, SIGNAL "clicked()", qApp, SLOT "quit()");
    this->connect($slider, SIGNAL "valueChanged(int)",
                  $lcd, SLOT "display(int)");

    my $layout = Qt4::VBoxLayout;
    $layout->addWidget($quit);
    $layout->addWidget($lcd);
    $layout->addWidget($slider);
    this->setLayout($layout);
}

package main;

use Qt4;
use MyWidget;

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $widget = MyWidget();
    $widget->show();
    return $app->exec();
} 

main();
