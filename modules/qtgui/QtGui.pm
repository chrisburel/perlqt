package PerlQt5::QtGui;

use strict;
use warnings;
use XSLoader;
use PerlQt5::QtCore;

our $VERSION = '1.0.0';

PerlQt5::QtGui::loadModule(__PACKAGE__, $VERSION);

sub import {
    my ($package, @exports) = @_;
    my $caller = (caller)[0];

    foreach my $export (@exports) {
        my $subpackage = "${package}::${export}";
        my $subpackageGlob = "${subpackage}::";
        my $alias = "${caller}::${export}::";
        {
            no strict 'refs';
            if (!exists ${"${package}::"}{"${export}::"}) {
                die "$package does not export $export\n";
            }
            *{$alias} = \*{$subpackageGlob};
        }
    }
}

sub loadModule {
    my ($module, $version) = @_;
    if ($^O eq 'MSWin32') {
        $module = 'Perl'. $module;
    }
    XSLoader::load($module, $version);
}

1;
