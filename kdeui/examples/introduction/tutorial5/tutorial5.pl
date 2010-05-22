#!/usr/bin/perl

use strict;
use warnings;

use KDEUi4;
use Qt4::GlobalSpace qw( ki18n );
use MainWindow;
 
sub main
{
    my $aboutData = KDE::AboutData( Qt4::ByteArray('tutorial5'), Qt4::ByteArray('tutorial5'),
            ki18n('Tutorial 5'), Qt4::ByteArray('1.0'),
            ki18n('A simple text area which can load and save.'),
            KDE::AboutData::License_GPL(),
            ki18n('Copyright (c) 2007 Developer') );
    unshift @ARGV, $0;
    KDE::CmdLineArgs::init( scalar @ARGV, \@ARGV, $aboutData );

    my $options = KDE::CmdLineOptions();
    $options->add(Qt4::ByteArray('+[file]' . ki18n('Document to open')));
    KDE::CmdLineArgs::addCmdLineOptions($options);

    my $app = KDE::Application();

    my $window = MainWindow();
    $window->show();

    my $args = KDE::CmdLineArgs::parsedArgs();
    if($args->count())
    {
        $window->openFile($args->url(0)->path());
    }

    return $app->exec();
}

exit main();
