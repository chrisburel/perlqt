#!/usr/bin/perl

use strict;
use warnings;
use blib;

use Qt;
use ImageViewer;

sub main {
    my $app = Qt::Application( \@ARGV );
    my $imageViewer = ImageViewer();
    $imageViewer->show();
    return $app->exec();
}

exit main();
