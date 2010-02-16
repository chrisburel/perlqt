#!/usr/local/bin/perl -w

use strict;
use warnings;
use blib;

package MyWidget;

use Qt;
use Qt::isa qw(Qt::QWidget);
use CannonField;
use LCDRange;

my @widgets;

sub NEW {
    shift->SUPER::NEW(@_);

    my $quit = Qt::QPushButton("&Quit");
    $quit->setFont(Qt::QFont("Times", 18, Qt::QFont::Bold()));

    this->connect($quit, SIGNAL "clicked()", Qt::qapp(), SLOT "quit()");

    my $angle = LCDRange();
    $angle->setRange(5, 70);

    my $force = LCDRange();
    $force->setRange(10, 50);

    my $cannonField = CannonField();

    this->connect($angle, SIGNAL 'valueChanged(int)',
                  $cannonField, SLOT 'setAngle(int)');
    this->connect($cannonField, SIGNAL 'angleChanged(int)',
                  $angle, SLOT 'setValue(int)');
    this->connect($force, SIGNAL 'valueChanged(int)',
                  $cannonField, SLOT 'setForce(int)');
    this->connect($cannonField, SIGNAL 'forceChanged(int)',
                  $force, SLOT 'setValue(int)');

    my $leftLayout = Qt::QVBoxLayout();
    $leftLayout->addWidget($angle);
    $leftLayout->addWidget($force);

    my $gridLayout = Qt::QGridLayout();
    $gridLayout->addWidget($quit, 0, 0);
    $gridLayout->addLayout($leftLayout, 1, 0);
    $gridLayout->addWidget($cannonField, 1, 1, 2, 1);
    $gridLayout->setColumnStretch(1, 10);
    this->setLayout($gridLayout);

    $angle->setValue(60);
    $force->setValue(25);
    $angle->setFocus();

    push @widgets, $angle;
    push @widgets, $force;
    push @widgets, $cannonField;
}

1;

package main;

use Qt;
use MyWidget;

sub main {
    my $widget = MyWidget();
    $widget->setGeometry(100, 100, 500, 355);
    $widget->show();
    return Qt::appexec();
} 

main();
