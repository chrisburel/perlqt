#!/usr/bin/perl -w

use strict;
use warnings;

package MyWidget;

use Qt;
use Qt::isa qw(Qt::Widget);

sub NEW {
    shift->SUPER::NEW(@_);

    this->setFixedSize(200, 120);

    my $quit = Qt::PushButton("Quit", this);
    $quit->setGeometry(62, 40, 75, 30);
    $quit->setFont(Qt::Font("Times", 18, Qt::Font::Bold()));

    this->connect($quit, SIGNAL "clicked()", qApp, SLOT "quit()");
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
