#!/usr/bin/perl

use strict;
use warnings;
use blib;

use Qt;
use WidgetGallery;

sub main {
    #Q_INIT_RESOURCE(styles);

    print "This example lacks necessary support from the underlying Smoke " .
        "object.  Displaying what I can...\n";
    my $app = Qt::Application( \@ARGV );
    my $gallery = WidgetGallery();
    $gallery->show();
    return $app->exec();
}

exit main();
