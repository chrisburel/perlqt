#!/usr/bin/perl

use strict;
use warnings;
use Qt;
use Client;

sub main
{
    my $app = Qt::Application(\@ARGV);
    my $client = Client();
    $client->show();
    return $client->exec();
}

exit main();
