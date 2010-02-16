#!/usr/bin/perl

use strict;
use warnings;
use Qt;
use Dialog;

sub main
{
    my $app = Qt::Application(\@ARGV);
    my $dialog = Dialog();
    return $dialog->exec();
}

exit main();
