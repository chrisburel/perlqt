#!/usr/bin/perl

use strict;
use warnings;
use Qt4;

use Database;
use MainWindow;

sub main
{
    my $app = Qt4::Application(\@ARGV);

    if (!Database::createConnection()) {
        return 1;
    }

    my $albumDetails = Qt4::File('albumdetails.xml');
    my $window = MainWindow('artists', 'albums', $albumDetails);
    $window->show();
    return $app->exec();
}

exit main();
