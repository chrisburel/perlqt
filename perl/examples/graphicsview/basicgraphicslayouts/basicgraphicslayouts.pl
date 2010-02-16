#!/usr/bin/perl

use strict;
use warnings;
use Qt;
use Window;

sub main
{
    my $app = Qt::Application( \@ARGV );

    my $scene = Qt::GraphicsScene();

    my $window = Window();
    $scene->addItem($window);
    my $view = Qt::GraphicsView($scene);
    $view->resize(600, 600);
    $view->show();

    return $app->exec();
}

exit main();
