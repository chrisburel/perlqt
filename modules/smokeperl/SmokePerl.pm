package SmokePerl;

use strict;
use warnings;
use XSLoader;

our $VERSION = '1.0.0';
my @methodHandlers;

SmokePerl::loadModule(__PACKAGE__, $VERSION);

sub loadModule {
    my ($module, $version) = @_;
    if ($^O eq 'MSWin32') {
        $module = 'Perl'. $module;
    }
    XSLoader::load($module, $version);
}

sub addMethodTypeHandler {
    my ($type) = @_;
    push @methodHandlers, $type;
}

sub getMethodTypeHandlers {
    return @methodHandlers;
}

package SmokePerl::Method;

use overload
    '&{}' => \&call,
    'bool' => \&bool,
    ;

use constant {
    mf_static => 0x01,
    mf_const => 0x02,
    mf_copyctor => 0x04,  # Copy constructor
    mf_internal => 0x08,   # For internal use only
    mf_enum => 0x10,   # An enum value
    mf_ctor => 0x20,
    mf_dtor => 0x40,
    mf_protected => 0x80,
    mf_attribute => 0x100,   # accessor method for a field
    mf_property => 0x200,    # accessor method of a property
    mf_virtual => 0x400,
    mf_purevirtual => 0x800,
    mf_signal => 0x1000, # method is a signal
    mf_slot => 0x2000,   # method is a slot
    mf_explicit => 0x4000    # method is an 'explicit' constructor
};

sub new {
    my ($class, $instance, $name, $flags, $code) = @_;

    foreach my $type (SmokePerl::getMethodTypeHandlers()) {
        if (my $method = $type->new($instance, $name, $flags, $code)) {
            return $method;
        }
    }

    return bless {
        instance => $instance,
        name => $name,
        code => $code,
    }, $class;
}

sub call {
    my $self = shift;
    return sub{ $self->{code}->($self->{instance}, @_) };
}

sub bool {
    return 1;
}

1;
