package PerlQt5;

use strict;
use warnings;

our $VERSION = '1.0.0';

sub import {
    my ($package, @exports) = @_;
    my $caller = (caller)[0];

    foreach my $export (@exports) {
        my $subpackageFile = "$package/$export.pm";
        my $subpackage = "${package}::${export}";
        my $subpackageGlob = "${subpackage}::";
        require $subpackageFile;
        $subpackage->import();

        my $alias = "${caller}::${export}::";
        {
            no strict 'refs';
            *{$alias} = \*{$subpackageGlob};
        }
    }
}

1;
