#!/usr/bin/perl -w

use strict;

use Qt4;

=begin

use Qt4::debug qw(
        ambiguous
        autoload
        calls
        gc
        signals
        slots
        verbose
);

=cut

use MainWindow;

=begin

sub dumpMetaMethods {
    my ( $meta ) = @_;

    print "Methods for ".$meta->className().":\n";
    foreach my $index ( 0..$meta->methodCount()-1 ) {
        my $metaMethod = $meta->method($index);
        print $metaMethod->signature() . "\n";
    }
    print "\n";
}

=cut

sub main {
    my $app = Qt4::Application();
    my $mainWin = MainWindow();
    #dumpMetaMethods(Qt4::_internal::getMetaObject('QMdiArea'));
    $mainWin->show();
    exit $app->exec();
}

main();
