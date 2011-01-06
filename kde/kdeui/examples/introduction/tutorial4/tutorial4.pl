#!/usr/bin/perl

use strict;
use warnings;

use KDEUi4;
use Qt::GlobalSpace qw( ki18n );
use MainWindow;
 
sub main
{
    my $aboutData = KDE::AboutData( Qt::ByteArray('tutorial4'), Qt::ByteArray('tutorial4'),
            ki18n('Tutorial 4'), Qt::ByteArray('1.0'),
            ki18n('A simple text area which can load and save.'),
            KDE::AboutData::License_GPL(),
            ki18n('Copyright (c) 2007 Developer') );
    KDE::CmdLineArgs::init( scalar @ARGV, \@ARGV, $aboutData );
    my $app = KDE::Application();

    my $window = MainWindow();
    $window->show();
    return $app->exec();
}

exit main();
