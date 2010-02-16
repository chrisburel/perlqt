#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use SearchBox;

sub main
{
    my $app = Qt4::Application(\@ARGV);
    my $searchEdit = SearchBox();
    $searchEdit->show();
    return $app->exec();
}

exit main();
