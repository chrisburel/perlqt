#!/usr/bin/perl

use strict;
use warnings;
use Qt4;

use RemoteControl;

sub main
{
    my $a = Qt4::Application(\@ARGV);
    my $w = RemoteControl();
    $w->show();
    $a->connect($a, SIGNAL 'lastWindowClosed()', $a, SLOT 'quit()');
    return $a->exec();
}

exit main();
