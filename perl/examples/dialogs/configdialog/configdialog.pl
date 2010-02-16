#!/usr/bin/perl

use strict;
use warnings;

use Qt4;

use ConfigDialog;

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $dialog = ConfigDialog();
    exit $dialog->exec();
}

main();
