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
    $window->show();
    return $app->exec();
}
# [0]

exit main();
