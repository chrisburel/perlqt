#!/usr/bin/perl

package Pong;

use strict;
use warnings;
use blib;

use Qt;
use Qt::isa qw( Qt::DBusAbstractAdaptor );

use Qt::signals
    aboutToQuit => [];
use Qt::slots
    'QDBusVariant query' => ['const QString&'],
    'QString value' => [],
    setValue => ['QString'],
    quit => [];

sub NEW {
    shift->SUPER::NEW( @_ );
}

# the property
sub value() {
    return this->{m_value};
}

sub setValue {
    my ($newValue) = @_;
    this->{m_value} = $newValue;
}

sub quit {
    Qt::Timer::singleShot(0, Qt::Application::instance(), SLOT 'quit()');
}

sub query {
    my ( $query ) = @_;
    my $q = lc $query;
    if ($q eq 'hello') {
        return Qt::DBusVariant('World');
    }
    if ($q eq 'ping') {
        return Qt::DBusVariant('Pong');
    }
    if ($q =~ m/the answer to life, the universe and everything/) {
        return Qt::DBusVariant(42);
    }
    if ($q =~ m/unladen swallow/) {
        if ($q =~ m/european/) {
            return Qt::DBusVariant(11.0);
        }
        return Qt::DBusVariant(Qt::ByteArray('african or european?'));
    }

    return Qt::DBusVariant('Sorry, I don\'t know the answer');
}

1;

package main;

use strict;
use warnings;
use blib;

use Qt;
use PingCommon qw( SERVICE_NAME );
use Pong;

sub main {
    my $app = Qt::Application( \@ARGV );

    print "Running complexpong\n";
    my $obj = Qt::Object();
    my $pong = Pong($obj);
    $pong->connect($app, SIGNAL 'aboutToQuit()', SIGNAL 'aboutToQuit()' );
    $pong->setValue(Qt::Variant('initial value'));
    Qt::DBusConnection::sessionBus()->registerObject('/', $obj);

    if (!Qt::DBusConnection::sessionBus()->registerService(SERVICE_NAME)) {
        printf STDERR "%s\n",
                Qt::DBusConnection::sessionBus()->lastError()->message();
        exit 1;
    }
    
    exit $app->exec();
}

main();
