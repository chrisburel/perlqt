#!/usr/bin/perl

use strict;
use warnings;

use Qt4;
use Dialog;

sub main {
    my $app = Qt4::Application( \@ARGV );

    my $dialog = Dialog();
    $dialog->show();
    exit $app->exec();
}

main();
