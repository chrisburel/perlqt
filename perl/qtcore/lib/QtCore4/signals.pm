package QtCore4::signals;
#
# Proposed usage:
#
# use QtCore4::signals changeSomething => ['int'];
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
    my $caller = $self eq 'QtCore4::signals' ? (caller)[0] : $self;
    my(@signals) = @_;
    my $meta = \%{ $caller . '::META' };

    # The perl metaObject holds info about signals and slots, inherited
    # sig/slots, etc.  This is what actually causes perl-defined sig/slots to
    # be executed.
    *{ "${caller}::metaObject" } = sub {
        return Qt::_internal::getMetaObject($caller);
    } unless defined &{ "${caller}::metaObject" };

    # This makes any call to the signal name call XS_SIGNAL
    Qt::_internal::installqt_metacall( $caller ) unless defined &{$caller."::qt_metacall"};

    for ( my $i = 0; $i < @signals; $i += 2 ) {
        my $signalname = $signals[$i];
        my $signalargs = $signals[$i+1];

        # Build the signature for this signal
        my $signature = join '', ("$signalname(", join(',', @{$signalargs}), ')');

        # Normalize the signature, might not be necessary
        $signature = Qt::MetaObject::normalizedSignature(
           $signature )->data();

        my $signal = {
            name => $signalname,
            signature => $signature,
        };

        push @{$meta->{signals}}, $signal;
        Qt::_internal::installsignal("${caller}::$signalname") unless defined &{ "${caller}::$signalname" };
    }
}

1;
