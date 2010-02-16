#!/usr/bin/perl

use strict;
use warnings;
use Qt;
use Server;

sub main
{
    my $app = Qt::Application(\@ARGV);
    my $server = Server();
    $server->show();
    return $server->exec();
}

exit main();
