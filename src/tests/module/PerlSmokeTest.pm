package PerlSmokeTest;

use strict;
use warnings;
use XSLoader;

our $VERSION = '1.0.0';
PerlSmokeTest::loadModule(__PACKAGE__, $VERSION);

sub loadModule {
    my ($module, $version) = @_;
    XSLoader::load($module, $version);
}
