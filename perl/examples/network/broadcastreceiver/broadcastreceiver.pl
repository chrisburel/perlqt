#!/usr/bin/perl

use strict;
use warnings;
use Qt;
use Receiver;

sub main
{
    my $app = Qt::Application(\@ARGV);
    my $receiver = Receiver();
    $receiver->show();
    return $receiver->exec();
}

exit main();
