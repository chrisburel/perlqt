package QtCore4::slots;
#
# Proposed usage:
#
# use QtCore4::slots changeSomething => ['int'];
#

use strict;
use warnings;
use Carp;
use QtCore4;

our $VERSION = 0.60;

sub import {
    no strict 'refs';
    my $self = shift;
    croak "Odd number of arguments in slot declaration" if @_%2;
    my $caller = $self eq 'QtCore4::slots' ? (caller)[0] : $self;
    my @slots = @_;
    my $meta = \%{ $caller . '::META' };

    # The perl metaObject holds info about signals and slots, inherited
    # sig/slots, etc.  This is what actually causes perl-defined sig/slots to
    # be executed.
    *{ "${caller}::metaObject" } = sub {
        return Qt::_internal::getMetaObject($caller);
    } unless defined &{ "${caller}::metaObject" };

    Qt::_internal::installqt_metacall( $caller ) unless defined &{$caller."::qt_metacall"};
    for ( my $i = 0; $i < @slots; $i += 2 ) {
        my $fullslotname = $slots[$i];
        my $slotargs = $slots[$i+1];

        # Determine the slot return type, if there is one
        my @returnParts = split / +/, $fullslotname;
        my $slotname = pop @returnParts; # Remove actual method name
        my $returnType = @returnParts ? join ' ', @returnParts : undef;

        # Build the signature for this slot
        my $signature = join '', ("$slotname(", join(',', @{$slotargs}), ')');

        # Normalize the signature, might not be necessary
        $signature = Qt::MetaObject::normalizedSignature(
            $signature )->data();

        my $slot = {
            name => $slotname,
            signature => $signature,
            returnType => $returnType,
        };

        push @{$meta->{slots}}, $slot;
    }
}

1;
