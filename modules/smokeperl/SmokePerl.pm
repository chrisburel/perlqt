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

sub new {
    my ($class, $instance, $name, $code) = @_;

    foreach my $type (SmokePerl::getMethodTypeHandlers()) {
        if (my $method = $type->new($instance, $name, $code)) {
            return $method;
        }
    }

    return bless {
        instance => $instance,
        name => $name,
    }, $class;
}

sub call {
    my $self = shift;
    return sub{
        my $method = $self->{name};
        return $self->{instance}->$method(@_);
    };
}

sub bool {
    return 1;
}

1;
