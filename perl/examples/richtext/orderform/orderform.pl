#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use MainWindow;

# [0]
sub main
{
    my $app = Qt4::Application(\@ARGV);
    my $window = MainWindow();
    $window->resize(640, 480);
    $window->show();
    $window->createSample();
    return $app->exec();
}
# [0]

exit main();
