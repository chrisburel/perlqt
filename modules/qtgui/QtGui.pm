package PerlQt5::QtGui;

use strict;
use warnings;
use XSLoader;
use PerlQt5::QtCore;

our $VERSION = '1.0.0';

PerlQt5::QtCore::loadModule(__PACKAGE__, $VERSION);

sub import {
    goto &PerlQt5::QtCore::import;
}

sub loadModule {
    my ($module, $version) = @_;
    if ($^O eq 'MSWin32') {
        $module =~ s/::/::Perl/;
    }
    XSLoader::load($module, $version);
}

package PerlQt5::QtGui::QGuiApplication;

sub new {
    my ($class, $argv) = @_;
    unshift @{$argv}, $0;
    return bless $class->QGuiApplication(scalar @{$argv}, $argv), $class;
}

1;
