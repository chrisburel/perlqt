#!/usr/local/bin/perl -w

use lib '/home/chris/src/qt/4/PerlQt/blib/lib';
use lib '/home/chris/src/qt/4/PerlQt/blib/arch';

use strict;
use warnings;
use Qt;

sub main {
    my $hello = Qt::QPushButton("Hello world!");

    $hello->show();
    return Qt::qapp()->exec();
}

main();
