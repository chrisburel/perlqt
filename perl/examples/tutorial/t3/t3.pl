#!/usr/bin/perl -w

use strict;
use warnings;

use Qt4;

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $window = Qt4::Widget();
    $window->resize(200, 120);

    my $quit = Qt4::PushButton("Quit", $window);
    $quit->setFont(Qt4::Font("Times", 18, Qt4::Font::Bold()));
    $quit->setGeometry(10, 40, 180, 40);
    Qt4::Object::connect($quit, SIGNAL "clicked()", $app, SLOT "quit()");

    $window->show();
    return $app->exec();
} 

main();
