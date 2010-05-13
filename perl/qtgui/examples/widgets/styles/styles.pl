#!/usr/bin/perl

use strict;
use warnings;

use Qt4;
use WidgetGallery;

sub main {
    #Q_INIT_RESOURCE(styles);

    print "This example lacks necessary support from the underlying Smoke " .
        "object.  Displaying what I can...\n";
    my $app = Qt4::Application( \@ARGV );
    my $gallery = WidgetGallery();
    $gallery->show();
    return $app->exec();
}

exit main();
