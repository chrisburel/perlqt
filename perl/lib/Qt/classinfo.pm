package Qt::classinfo;
use Carp;
#
# Proposed usage:
#
# use Qt::classinfo key => value;
#

use Qt;

sub import {
    no strict 'refs';
    my $self = shift;
    croak "Odd number of arguments in classinfo declaration" if @_%2;
    my $caller = $self eq 'Qt::classinfo' ? (caller)[0] : $self;
    my(%classinfos) = @_;
    my $meta = \%{ $caller . '::META' };

    # See Qt::slots for explanation of this sub
    *{ "${caller}::metaObject" } = sub {
        return Qt::_internal::getMetaObject($caller);
    } unless defined &{ "${caller}::metaObject" };

    Qt::_internal::installqt_metacall( $caller ) unless defined &{$caller."::qt_metacall"};

    $meta->{dbus} = undef;

    foreach my $key ( keys %classinfos ) {
        my $value = $classinfos{$key};

        my $classinfo = {
            $key => $value
        };

        push @{$meta->{classinfos}}, $classinfo;

        # This affects the way the meta methods are defined.  If $meta->{dbus}
        # is true, the methods get declared public.
        $meta->{dbus} = 1 if $key eq 'D-Bus Interface';
    }
}

1;
