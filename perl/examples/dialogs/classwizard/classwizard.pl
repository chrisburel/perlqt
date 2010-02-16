#!/usr/bin/perl

use strict;
use warnings;

use Qt4;

use ClassWizard;

sub main {
    my $app = Qt4::Application(\@ARGV);

    my $translatorFileName = 'qt_';
    $translatorFileName .= Qt4::Locale::system()->name();
    my $translator = Qt4::Translator($app);
    if ($translator->load($translatorFileName, Qt4::LibraryInfo::location(Qt4::LibraryInfo::TranslationsPath()))) {
        $app->installTranslator($translator);
    }

    my $wizard = ClassWizard();
    $wizard->show();
    exit $app->exec();
}

main();
