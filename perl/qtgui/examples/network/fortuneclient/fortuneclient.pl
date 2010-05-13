#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use Client;

sub main
{
    my $app = Qt4::Application(\@ARGV);
    my $client = Client();
    $client->show();
    return $client->exec();
}

exit main();
