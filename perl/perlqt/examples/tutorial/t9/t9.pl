#!/usr/bin/perl -w

use strict;
use warnings;

package MyWidget;

use Qt4;
use Qt4::isa qw(Qt4::Widget);
use CannonField;
use LCDRange;

sub NEW {
    shift->SUPER::NEW(@_);

    my $quit = Qt4::PushButton("Quit");
    $quit->setFont(Qt4::Font("Times", 18, Qt4::Font::Bold()));

    this->connect($quit, SIGNAL "clicked()", qApp, SLOT "quit()");

    my $angle = LCDRange();
    $angle->setRange(5, 70);

    my $cannonField = CannonField();

    this->connect($angle, SIGNAL 'valueChanged(int)',
                  $cannonField, SLOT 'setAngle(int)');
    this->connect($cannonField, SIGNAL 'angleChanged(int)',
                  $angle, SLOT 'setValue(int)');

    my $gridLayout = Qt4::GridLayout();
    $gridLayout->addWidget($quit, 0, 0);
    $gridLayout->addWidget($angle, 1, 0);
    $gridLayout->addWidget($cannonField, 1, 1, 2, 1);
    $gridLayout->setColumnStretch(1, 10);
    this->setLayout($gridLayout);

    $angle->setValue(60);
    $angle->setFocus();
}

1;

package main;

use Qt4;
use MyWidget;

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $widget = MyWidget();
    $widget->setGeometry(100, 100, 500, 355);
    $widget->show();
    return $app->exec();
} 

main();
