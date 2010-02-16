#!/usr/bin/perl

use strict;
use warnings;
use Qt;
use Sender;

sub main
{
    my $app = Qt::Application(\@ARGV);
    my $sender = Sender();
    $sender->show();
    return $sender->exec();
}

exit main();
