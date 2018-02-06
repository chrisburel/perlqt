package PerlQt5::QtWidgets;

use strict;
use warnings;
use XSLoader;
use PerlQt5::QtGui;

our $VERSION = '1.0.0';

PerlQt5::QtCore::loadModule(__PACKAGE__, $VERSION);

sub import {
    goto &PerlQt5::QtCore::import;
}

package PerlQt5::QtWidgets::QApplication;

sub new {
    my ($class, $argv) = @_;
    unshift @{$argv}, $0;
    return bless $class->QApplication(scalar @{$argv}, $argv), $class;
}

1;
