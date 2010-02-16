package Qt4::debug;

use strict;
use warnings;
use Qt4;

our $VERSION = 0.60;

our %channel = (
    'ambiguous' => 0x01,
    'autoload' => 0x02,
    'calls' => 0x04,
    'gc' => 0x08,
    'virtual' => 0x10,
    'verbose' => 0x20,
    'signals' => 0x40,
    'slots' => 0x80,
    'all' => 0xff
);

sub dumpMetaMethods {
    my ( $object ) = @_;

    # Did we get an object in, or just a class name?
    my $className = ref $object ? ref $object : $object;
    $className =~ s/^ *//;
    my $meta = Qt4::_internal::getMetaObject( $className );

    if ( $meta->methodCount() ) {
        print join '', 'Methods for ', $meta->className(), ":\n"
    }
    else {
        print join '', 'No methods for ', $meta->className(), ".\n";
    }
    foreach my $index ( 0..$meta->methodCount()-1 ) {
        my $metaMethod = $meta->method($index);
        print $metaMethod->typeName . ' ' if $metaMethod->typeName;
        print $metaMethod->signature() . "\n";
    }
    print "\n";

    if ( $meta->classInfoCount() ) {
        print join '', 'Class info for ', $meta->className(), ":\n"
    }
    else {
        print join '', 'No class info for ', $meta->className(), ".\n";
    }
    foreach my $index ( 0..$meta->classInfoCount()-1 ) {
        my $classInfo = $meta->classInfo($index);
        print join '', '\'', $classInfo->name, '\' => \'', $classInfo->value, "'\n";
    }
    print "\n";
}

sub import {
    shift;
    my $db = (@_) ? 0x00 : 0x01;
    my $usage = 0;
    for my $ch(@_) {
        if( exists $channel{$ch}) {
             $db |= $channel{$ch};
        } else {
             warn "Unknown debugging channel: $ch\n";
             $usage++;
        }
    }
    Qt4::_internal::setDebug($db);    
    print "Available channels: \n\t".
          join("\n\t", sort keys %channel).
          "\n" if $usage;
}

sub unimport {
    Qt4::_internal::setDebug(0);    
}

1;
