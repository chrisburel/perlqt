#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use FtpWindow;

sub main
{
    my $app = Qt4::Application(\@ARGV);
    my $ftpWin = FtpWindow();
    $ftpWin->show();
    return $ftpWin->exec();
}

exit main();
