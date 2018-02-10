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

package SmokePerl::Enum;

use overload
    '==' => sub { return applyOperator(\&equal, @_) },
    '&' => sub { return applyOperatorBless(\&and, @_) },
    '|' => sub { return applyOperatorBless(\&or, @_) },
    '^' => sub { return applyOperatorBless(\&xor, @_) },
    '~' => sub { return ~${$_[0]} },
    '0+' => sub { return ${$_[0]} },
    '""' => sub { return ref($_[0]) . "(${$_[0]})"; },
    ;

sub and($$) {
    return $_[0] & $_[1];
}

sub equal($$) {
    return $_[0] == $_[1];
}

sub or($$) {
    return $_[0] | $_[1];
}

sub xor($$) {
    return $_[0] ^ $_[1];
}

sub applyOperator {
    my ($opFunc) = shift;
    if (ref $_[1]) {
        return $opFunc->(${$_[0]}, ${$_[1]});
    }
    elsif ($_[2]) {
        # arguments have been swapped
        return $opFunc->($_[1], ${$_[0]});
    }
    return $opFunc->(${$_[0]}, $_[1]);
}

sub applyOperatorBless {
    return bless \applyOperator(@_), ref $_[1];
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
