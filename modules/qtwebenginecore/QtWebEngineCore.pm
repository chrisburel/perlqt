package PerlQt5::QtWebEngineCore;

use strict;
use warnings;
use XSLoader;
use PerlQt5::QtQuick;
use PerlQt5::QtGui;
use PerlQt5::QtNetwork;
use PerlQt5::QtPositioning;
use PerlQt5::QtWebChannel;

our $VERSION = '1.0.0';

PerlQt5::QtCore::loadModule(__PACKAGE__, $VERSION);

sub import {
    goto &PerlQt5::QtCore::import;
}

1;
