#!/usr/bin/perl

use strict;
use warnings;
use blib;

use KDEUi4;
use Qt4::GlobalSpace qw( ki18n );
use MainWindow;
 
sub main {
    my $aboutData = KDE::AboutData( Qt4::ByteArray('tutorial3'), Qt4::ByteArray('tutorial3'),
            ki18n('Tutorial 3'), Qt4::ByteArray('1.0'),
            ki18n('A simple text area using KAction etc.'),
            KDE::AboutData::License_GPL(),
            ki18n('Copyright (c) 2007 Developer') );
    KDE::CmdLineArgs::init( scalar @ARGV, \@ARGV, $aboutData );
    my $app = KDE::Application();

    my $window = MainWindow();
    $window->show();
    return $app->exec();
}

exit main();
