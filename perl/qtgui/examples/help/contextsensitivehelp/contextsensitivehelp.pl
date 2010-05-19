#!/usr/bin/perl

use strict;
use warnings;
use QtCore4;
use QtGui4;

use WateringConfigDialog;

sub main
{
    die "This example does not yet work.  The bindings do not provide support for QHelpEngineCore.\n";
    my $a = Qt::Application(\@ARGV);
    my $dia = WateringConfigDialog();
    return $dia->exec();
}

exit main();
