#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use MainWindow;

sub main
{
    my $app = Qt4::Application(\@ARGV);

    my $locale = Qt4::Locale::system()->name();

# [0]
    my $translator = Qt4::Translator();
    $translator->load('trollprint_' . $locale);
    $app->installTranslator($translator);
# [0]

    my $mainWindow = MainWindow();
    $mainWindow->show();
    return $app->exec();
}

exit main();
