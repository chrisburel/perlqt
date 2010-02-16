package Qt4::slots;
use Carp;
#
# Proposed usage:
#
# use Qt4::slots changeSomething => ['int'];
#

use Qt4;

sub import {
    no strict 'refs';
    my $self = shift;
    croak "Odd number of arguments in slot declaration" if @_%2;
    my $caller = $self eq 'Qt4::slots' ? (caller)[0] : $self;
    my(%slots) = @_;
    my $meta = \%{ $caller . '::META' };

    # The perl metaObject holds info about signals and slots, inherited
    # sig/slots, etc.  This is what actually causes perl-defined sig/slots to
    # be executed.
    *{ "${caller}::metaObject" } = sub {
        return Qt4::_internal::getMetaObject($caller);
    } unless defined &{ "${caller}::metaObject" };

    Qt4::_internal::installqt_metacall( $caller ) unless defined &{$caller."::qt_metacall"};
    foreach my $fullslotname ( keys %slots ) {

        # Determine the slot return type, if there is one
        my @returnParts = split / +/, $fullslotname;
        my $slotname = pop @returnParts; # Remove actual method name
        $returnType = @returnParts ? join ' ', @returnParts : undef;

        # Build the signature for this slot
        my $signature = join '', ("$slotname(", join(',', @{$slots{$fullslotname}}), ')');

        # Normalize the signature, might not be necessary
        $signature = Qt4::MetaObject::normalizedSignature(
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
