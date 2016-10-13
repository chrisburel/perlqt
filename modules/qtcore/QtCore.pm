package PerlQt5::QtCore;

use strict;
use warnings;
use XSLoader;
use SmokePerl;

our $VERSION = '1.0.0';

PerlQt5::QtCore::loadModule(__PACKAGE__, $VERSION);
SmokePerl::addMethodTypeHandler('PerlQt5::QtCore::Signal');
SmokePerl::addMethodTypeHandler('PerlQt5::QtCore::Slot');

sub import {
    my ($package, @exports) = @_;
    my $caller = (caller)[0];

    foreach my $export (@exports) {
        my $subpackage = "${package}::${export}";
        my $alias = "${caller}::${export}";
        {
            no strict 'refs';
            my $isGlob = exists ${"${package}::"}{"${export}::"} ? '::' : '';
            if (!$isGlob && !exists ${"${package}::"}{"${export}"}) {
                die "$package does not export $export\n";
            }
            *{"${alias}${isGlob}"} = \*{"${subpackage}${isGlob}"};
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

sub SIGNAL($) {
    return '2'.$_[0];
}

sub SLOT($) {
    return '1'.$_[0];
}

package PerlQt5::QtCore::Signal;

use base qw(SmokePerl::Method);

sub new {
    my ($class, $instance, $name, $flags, $code) = @_;
    if (defined $flags && $flags & SmokePerl::Method::mf_signal) {
        return bless {
            instance => $instance,
            name => $name,
            code => $code,
        }, $class;
    }
    return;
}

package PerlQt5::QtCore::Slot;

use base qw(SmokePerl::Method);

sub new {
    my ($class, $instance, $name, $flags, $code) = @_;
    if (defined $flags && $flags & SmokePerl::Method::mf_slot) {
        return bless {
            instance => $instance,
            name => $name,
            code => $code,
        }, $class;
    }
    return;
}

package PerlQt5::QtCore::QObject;

use B;

sub MODIFY_CODE_ATTRIBUTES {
    my $package = shift;
    my $code = shift;
    my @attrs = @_;
    my @unhandled;

    # Get the name of the subroutine
    my $cv = B::svref_2object($code);
    my $name = $cv->GV->NAME;

    # Add a slot with this name to the metaObject
    my $metaObject = $package->staticMetaObject();
    for my $attr (@attrs) {
        if (my ($argTypes) = ($attr =~ m/^Slot\((.*)\)$/)) {
            my @argTypes = split /, */, $argTypes;
            PerlQt5::QtCore::_internal::addSlot($metaObject, $name, \@argTypes);
            $metaObject = $package->staticMetaObject();
        }
    }

    return;
}

1;
