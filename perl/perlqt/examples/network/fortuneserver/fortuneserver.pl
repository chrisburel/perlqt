#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use Server;

sub main
{
    my $app = Qt4::Application(\@ARGV);
    my $server = Server();
    $server->show();
    return $server->exec();
}

exit main();
