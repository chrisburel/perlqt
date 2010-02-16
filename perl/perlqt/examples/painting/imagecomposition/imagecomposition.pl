#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use ImageComposer;

# [0]
sub main
{
    my $app = Qt4::Application(\@ARGV);
    my $composer = ImageComposer();
    $composer->show();
    return $app->exec();
}
# [0]

exit main();
