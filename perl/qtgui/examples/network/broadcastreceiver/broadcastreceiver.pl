#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use Receiver;

sub main
{
    my $app = Qt4::Application(\@ARGV);
    my $receiver = Receiver();
    $receiver->show();
    return $receiver->exec();
}

exit main();
