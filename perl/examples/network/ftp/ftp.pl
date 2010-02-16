#!/usr/bin/perl

use strict;
use warnings;
use Qt;
use FtpWindow;

sub main
{
    my $app = Qt::Application(\@ARGV);
    my $ftpWin = FtpWindow();
    $ftpWin->show();
    return $ftpWin->exec();
}

exit main();
