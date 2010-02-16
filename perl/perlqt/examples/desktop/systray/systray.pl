#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use Window;

sub main
{
    my $app = Qt4::Application( \@ARGV );

    if (!Qt4::SystemTrayIcon::isSystemTrayAvailable()) {
        Qt4::MessageBox::critical(0, Qt4::Object::this->tr('Systray'),
                              Qt4::Object::this->tr('I couldn\'t detect any system tray ' .
                                          'on this system.'));
        return 1;
    }
    Qt4::Application::setQuitOnLastWindowClosed(0);

    my $window = Window();
    $window->show();
    return $app->exec();
}

exit main();
