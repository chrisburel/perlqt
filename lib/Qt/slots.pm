package Qt::slots;
use Carp;
#
# Proposed usage:
#
# use Qt::slots changeSomething => ['int'];
#

use Qt;

sub import {
    no strict 'refs';
    my $self = shift;
    croak "Odd number of arguments in slot declaration" if @_%2;
    my $caller = $self eq 'Qt::slots' ? (caller)[0] : $self;
    my(%slots) = @_;
    my $meta = \%{ $caller . '::META' };

    Qt::_internal::installqt_metacall( $caller ) unless defined &{$caller."::qt_metacall"};
    foreach my $slotname ( keys %slots ) {
        # Build the signature for this slot
        my $signature = join '', ("$slotname(", join(',', @{$slots{$slotname}}), ')');

        # Normalize the signature, might not be necessary
        $signature = Qt::QMetaObject::normalizedSignature(
           $signature )->data();

        my $slot = {
            name => $slotname,
            signature => $signature,
        };

        push @{$meta->{slots}}, $slot;
    }
}

1;
