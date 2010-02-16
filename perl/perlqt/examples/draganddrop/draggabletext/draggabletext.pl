#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use DragWidget;

sub main
{
    my $app = Qt4::Application(\@ARGV);
    my $window = DragWidget();
    $window->show();
    return $app->exec();
}

exit main();
