#!/usr/bin/perl -w

use strict;
use warnings;

use Qt4;

sub main {
    my $app = Qt4::Application(\@ARGV);
    my $hello = Qt4::PushButton("Hello world!");
    $hello->show();
    exit $app->exec();
}

main();
