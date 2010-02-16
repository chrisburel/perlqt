#!/usr/bin/perl

use strict;
use warnings;
use blib;

use Qt;

use LicenseWizard;

sub main {

    my $app = Qt::Application( \@ARGV );

    my $translatorFileName = 'qt_';
    $translatorFileName .= Qt::Locale::system()->name();
    my $translator = Qt::Translator($app);
    if ($translator->load($translatorFileName, Qt::LibraryInfo::location(Qt::LibraryInfo::TranslationsPath()))) {
        $app->installTranslator($translator);
    }
    
    my $wizard = LicenseWizard();
    $wizard->show();
    return $app->exec();
}

main();
