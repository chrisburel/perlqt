package PerlQt5::QtQuick;

use strict;
use warnings;
use XSLoader;
use PerlQt5::QtGui;
use PerlQt5::QtQml;
use PerlQt5::QtNetwork;

our $VERSION = '1.0.0';

PerlQt5::QtCore::loadModule(__PACKAGE__, $VERSION);

sub import {
    goto &PerlQt5::QtCore::import;
}

1;
