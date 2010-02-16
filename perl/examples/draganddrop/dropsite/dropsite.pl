#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use DropSiteWindow;

# [main() function]
sub main
{
    my $app = Qt4::Application(\@ARGV);
    my $window = DropSiteWindow();
    $window->show();
    return $app->exec();
}
# [main() function]

exit main();
