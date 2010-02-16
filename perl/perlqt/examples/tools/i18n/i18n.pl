#!/usr/bin/perl

use strict;
use warnings;

use Qt4;
use LanguageChooser;
use MainWindow;

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $chooser = LanguageChooser();
    $chooser->show();
    exit $app->exec();
}

main();
