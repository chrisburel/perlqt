#!/usr/bin/perl

use strict;
use warnings;

use Qt4;
use ControllerWindow;

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $controller = ControllerWindow();
    $controller->show();
    return $app->exec();
}

exit main();
