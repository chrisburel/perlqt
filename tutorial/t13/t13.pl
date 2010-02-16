#!/usr/local/bin/perl -w

use strict;
use warnings;
use blib;

package main;

use Qt;
use GameBoard;

sub dumpMetaMethods {
    my ( $meta ) = @_;

    print "Methods for ".$meta->className().":\n";
    foreach my $index ( 0..$meta->methodCount()-1 ) {
        my $metaMethod = $meta->method($index);
        print $metaMethod->signature() . "\n";
    }
    print "\n";
}

sub main {
    my $widget = GameBoard();
    #dumpMetaMethods(Qt::_internal::getMetaObject('GameBoard'));
    $widget->setGeometry(100, 100, 500, 355);
    $widget->show();
    return Qt::qapp->exec();
} 

main();
