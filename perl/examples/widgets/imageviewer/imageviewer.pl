#!/usr/bin/perl

use strict;
use warnings;

use Qt4;
use ImageViewer;

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $imageViewer = ImageViewer();
    $imageViewer->show();
    return $app->exec();
}

exit main();
