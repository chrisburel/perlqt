#!/usr/bin/perl

use strict;
use warnings;

use Qt4;

use MoviePlayer;

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $player = MoviePlayer();
    $player->show();
    exit $app->exec();
}

main();
