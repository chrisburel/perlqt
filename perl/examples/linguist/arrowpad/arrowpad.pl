#!/usr/bin/perl

use strict;
use warnings;
use Qt;
use MainWindow;

# [0]
sub main
# [0] //! [1]
{
    my $app = Qt::Application(\@ARGV);

    my $locale = Qt::Locale::system()->name();

# [2]
    my $translator = Qt::Translator();
# [2] //! [3]
    $translator->load('arrowpad_' . $locale . '.qm');
    $app->installTranslator($translator);
# [1] //! [3]

    my $mainWindow = MainWindow();
    $mainWindow->show();
    return $app->exec();
}

exit main();
