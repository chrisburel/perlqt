package Qt::debug;
use Qt;

our %channel = (
    'ambiguous' => 0x01,
    'autoload' => 0x02,
    'calls' => 0x04,
    'gc' => 0x08,
    'virtual' => 0x10,
    'verbose' => 0x20,
    'signals' => 0x40,
    'slots' => 0x80,
    'all' => 0xffff
);

sub dumpMetaMethods {
    my ( $object ) = @_;

    my $objName = ref $object;
    $objName =~ s/^ *//;
    my $meta = Qt::_internal::getMetaObject( $objName );

    print "Methods for ".$meta->className().":\n";
    foreach my $index ( 0..$meta->methodCount()-1 ) {
        my $metaMethod = $meta->method($index);
        print $metaMethod->signature() . "\n";
    }
    print "\n";
}

sub import {
    shift;
    my $db = (@_)? 0x0000 : (0x01|0x80);
    my $usage = 0;
    for my $ch(@_) {
        if( exists $channel{$ch}) {
             $db |= $channel{$ch};
        } else {
             warn "Unknown debugging channel: $ch\n";
             $usage++;
        }
    }
    Qt::_internal::setDebug($db);    
    print "Available channels: \n\t".
          join("\n\t", sort keys %channel).
          "\n" if $usage;
}

sub unimport {
    Qt::_internal::setDebug(0);    
}

1;
