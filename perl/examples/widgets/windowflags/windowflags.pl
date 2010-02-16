#!/usr/bin/perl

use strict;
use warnings;

use Qt;
use ControllerWindow;

sub main {
    my $app = Qt::Application( \@ARGV );
    my $controller = ControllerWindow();
    $controller->show();
    return $app->exec();
}

exit main();
