#!/usr/bin/perl

use strict;
use warnings;
use Qt4;

use Connection;
use View;

sub main
{
    my $app = Qt4::Application(\@ARGV);

    if (!Connection::createConnection()) {
        return 1;
    }

    my $view = View('offices', 'images');
    $view->show();
    #Qt4::Application::setNavigationMode(Qt4::NavigationModeCursorAuto());
    return $app->exec();
}

exit main();
