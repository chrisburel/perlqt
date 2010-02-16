#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use MainWindow;

# [0]
sub main
# [0] //! [1]
{
    my $app = Qt4::Application(\@ARGV);

    my $locale = Qt4::Locale::system()->name();

# [2]
    my $translator = Qt4::Translator();
# [2] //! [3]
    $translator->load('arrowpad_' . $locale . '.qm');
    $app->installTranslator($translator);
# [1] //! [3]

    my $mainWindow = MainWindow();
    $mainWindow->show();
    return $app->exec();
}

exit main();
