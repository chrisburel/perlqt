#!/usr/bin/perl

use strict;
use warnings;
use Qt;
use DragWidget;

sub main
{
    my $app = Qt::Application(\@ARGV);
    my $window = DragWidget();
    $window->show();
    return $app->exec();
}

exit main();
