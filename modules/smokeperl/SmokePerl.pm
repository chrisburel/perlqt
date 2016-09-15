package SmokePerl;

use strict;
use warnings;
use XSLoader;

our $VERSION = '1.0.0';

SmokePerl::loadModule(__PACKAGE__, $VERSION);

sub loadModule {
    my ($module, $version) = @_;
    if ($^O eq 'MSWin32') {
        $module = 'Perl'. $module;
    }
    XSLoader::load($module, $version);
}

