#!/usr/bin/perl -w

use strict;
use warnings;

package MyWidget;

use Qt4;
use Qt4::isa qw(Qt4::Widget);

sub NEW {
    shift->SUPER::NEW(@_);

    setFixedSize(200, 120);

    my $quit = Qt4::PushButton("Quit", this);
    $quit->setGeometry(62, 40, 75, 30);
    $quit->setFont(Qt4::Font("Times", 18, Qt4::Font::Bold()));

    this->connect($quit, SIGNAL "clicked()", qApp, SLOT "quit()");
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
