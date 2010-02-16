#!/usr/bin/perl

use strict;
use warnings;
use blib;

use Qt;

use ConfigDialog;

sub main {
    my $app = Qt::Application( \@ARGV );
    my $dialog = ConfigDialog();
    exit $dialog->exec();
}

main();
