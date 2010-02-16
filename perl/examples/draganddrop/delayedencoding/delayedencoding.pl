#!/usr/bin/perl

use strict;
use warnings;
use blib;

use Qt;
use SourceWidget;

sub main {
    my $app = Qt::Application( \@ARGV );
    my $window = SourceWidget();
    $window->show();
    exit $app->exec();
}

main();
