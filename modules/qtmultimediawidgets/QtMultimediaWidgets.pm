package PerlQt5::QtMultimediaWidgets;

use strict;
use warnings;
use XSLoader;
use PerlQt5::QtWidgets;
use PerlQt5::QtNetwork;
use PerlQt5::QtMultimedia;
use PerlQt5::QtOpenGL;

our $VERSION = '1.0.0';

PerlQt5::QtCore::loadModule(__PACKAGE__, $VERSION);

sub import {
    goto &PerlQt5::QtCore::import;
}

1;
