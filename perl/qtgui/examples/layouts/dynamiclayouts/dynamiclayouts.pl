#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use Dialog;

sub main
{
    my $app = Qt4::Application(\@ARGV);
    my $dialog = Dialog();
    return $dialog->exec();
}

exit main();
