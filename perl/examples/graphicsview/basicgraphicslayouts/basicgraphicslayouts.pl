#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use Window;

sub main
{
    my $app = Qt4::Application( \@ARGV );

    my $scene = Qt4::GraphicsScene();

    my $window = Window();
    $scene->addItem($window);
    my $view = Qt4::GraphicsView($scene);
    $view->resize(600, 600);
    $view->show();

    return $app->exec();
}

exit main();
