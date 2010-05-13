#!/usr/bin/perl

use strict;
use warnings;
use Qt4;

use WateringConfigDialog;

sub main
{
    die "This example does not yet work.  The bindings do not provide support for QHelpEngineCore.\n";
    my $a = Qt4::Application(\@ARGV);
    my $dia = WateringConfigDialog();
    return $dia->exec();
}

exit main();
