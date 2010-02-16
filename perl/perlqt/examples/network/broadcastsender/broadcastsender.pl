#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use Sender;

sub main
{
    my $app = Qt4::Application(\@ARGV);
    my $sender = Sender();
    $sender->show();
    return $sender->exec();
}

exit main();
