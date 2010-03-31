package Qt4::signals;
#
# Proposed usage:
#
# use Qt4::signals changeSomething => ['int'];
#

use strict;
use warnings;
use Carp;
use QtCore4;

our $VERSION = 0.60;

sub import {
    no strict 'refs';
    my $self = shift;
    croak "Odd number of arguments in signal declaration" if @_%2;
    my $caller = $self eq 'Qt4::signals' ? (caller)[0] : $self;
    my(%signals) = @_;
    my $meta = \%{ $caller . '::META' };

    # The perl metaObject holds info about signals and slots, inherited
    # sig/slots, etc.  This is what actually causes perl-defined sig/slots to
    # be executed.
    *{ "${caller}::metaObject" } = sub {
        return Qt4::_internal::getMetaObject($caller);
    } unless defined &{ "${caller}::metaObject" };

    # This makes any call to the signal name call XS_SIGNAL
    Qt4::_internal::installqt_metacall( $caller ) unless defined &{$caller."::qt_metacall"};

    foreach my $signalname ( keys %signals ) {
        # Build the signature for this signal
        my $signature = join '', ("$signalname(", join(',', @{$signals{$signalname}}), ')');

        # Normalize the signature, might not be necessary
        $signature = Qt4::MetaObject::normalizedSignature(
           $signature )->data();

        my $signal = {
            name => $signalname,
            signature => $signature,
        };

        push @{$meta->{signals}}, $signal;
        Qt4::_internal::installsignal("${caller}::$signalname") unless defined &{ "${caller}::$signalname" };
    }
}

1;
