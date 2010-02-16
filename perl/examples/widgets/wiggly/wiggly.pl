#!/usr/bin/perl

use strict;
use warnings;

use Qt;
use Dialog;

sub main {
    my $app = Qt::Application( \@ARGV );

    my $dialog = Dialog();
    $dialog->show();
    exit $app->exec();
}

main();
