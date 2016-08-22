package PerlQt5::QtCore;

use strict;
use warnings;
use XSLoader;

our $VERSION = '1.0.0';

PerlQt5::QtCore::loadModule(__PACKAGE__, $VERSION);

sub loadModule {
    my ($module, $version) = @_;
    if ($^O eq 'MSWin32') {
        $module = 'Perl'. $module;
    }
    XSLoader::load($module, $version);
}
