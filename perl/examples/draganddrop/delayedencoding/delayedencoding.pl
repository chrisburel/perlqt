#!/usr/bin/perl

use strict;
use warnings;

use Qt4;
use SourceWidget;

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $window = SourceWidget();
    $window->show();
    exit $app->exec();
}

main();
