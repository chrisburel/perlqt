package PerlQt5::QtQuickWidgets;

use strict;
use warnings;
use XSLoader;
use PerlQt5::QtWidgets;
use PerlQt5::QtQuick;
use PerlQt5::QtQml;

our $VERSION = '1.0.0';

PerlQt5::QtCore::loadModule(__PACKAGE__, $VERSION);

sub import {
    goto &PerlQt5::QtCore::import;
}

1;
