#!/usr/bin/perl -w

use strict;
use warnings;

use Qt4;

sub main {
    my $app = Qt4::Application(\@ARGV);
    my $quit = Qt4::PushButton("Quit");
    $quit->resize(150, 30);
    my $font = Qt4::Font("Times", 18, 75);
    $quit->setFont( $font );

    Qt4::Object::connect( $quit, SIGNAL "clicked()",
                         $app,  SLOT "quit()" );

    $quit->show();

    return $app->exec();
}

main();
