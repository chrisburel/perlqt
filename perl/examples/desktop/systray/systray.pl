#!/usr/bin/perl

use strict;
use warnings;
use Qt;
use Window;

sub main
{
    my $app = Qt::Application( \@ARGV );

    if (!Qt::SystemTrayIcon::isSystemTrayAvailable()) {
        Qt::MessageBox::critical(0, Qt::Object::this->tr('Systray'),
                              Qt::Object::this->tr('I couldn\'t detect any system tray ' .
                                          'on this system.'));
        return 1;
    }
    Qt::Application::setQuitOnLastWindowClosed(0);

    my $window = Window();
    $window->show();
    return $app->exec();
}

exit main();
