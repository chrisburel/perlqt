package PerlQt5::QtHelp;

use strict;
use warnings;
use XSLoader;
use PerlQt5::QtWidgets;
use PerlQt5::QtSql;
use PerlQt5::QtNetwork;

our $VERSION = '1.0.0';

PerlQt5::QtCore::loadModule(__PACKAGE__, $VERSION);

sub import {
    goto &PerlQt5::QtCore::import;
}

1;
