#!/usr/bin/perl

use strict;
use warnings;

use Qt4;

use FindDialog;

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $dialog = FindDialog();
    exit $dialog->exec();
}

main();
