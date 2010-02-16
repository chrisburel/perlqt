#!/usr/bin/perl

package Pong;

use strict;
use warnings;

use Qt4;
use Qt4::isa qw( Qt4::DBusAbstractAdaptor );
use Qt4::classinfo
    'D-Bus Interface' => 'com.trolltech.QtDBus.ComplexPong.Pong';

use Qt4::signals
    aboutToQuit => [];
use Qt4::slots
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
    Qt4::Timer::singleShot(0, Qt4::Application::instance(), SLOT 'quit()');
}

sub query {
    my ( $query ) = @_;
    my $q = lc $query;
    if ($q eq 'hello') {
        return Qt4::DBusVariant(Qt4::String('World'));
    }
    if ($q eq 'ping') {
        return Qt4::DBusVariant(Qt4::String('Pong'));
    }
    if ($q =~ m/the answer to life, the universe and everything/) {
        return Qt4::DBusVariant(Qt4::Int(42));
    }
    if ($q =~ m/unladen swallow/) {
        if ($q =~ m/european/) {
            return Qt4::DBusVariant(Qt4::Int(11.0));
        }
        return Qt4::DBusVariant(Qt4::String('african or european?'));
    }

    return Qt4::DBusVariant(Qt4::String('Sorry, I don\'t know the answer'));
}

1;

package main;

use strict;
use warnings;

use Qt4;
use PingCommon qw( SERVICE_NAME );
use Pong;

sub main {
    my $app = Qt4::Application( \@ARGV );

    my $obj = Qt4::Object();
    my $pong = Pong($obj);
    $pong->connect($app, SIGNAL 'aboutToQuit()', SIGNAL 'aboutToQuit()' );
    $pong->setValue(Qt4::Variant(Qt4::String('initial value')));
    Qt4::DBusConnection::sessionBus()->registerObject('/', $obj);

    if (!Qt4::DBusConnection::sessionBus()->registerService(SERVICE_NAME)) {
        printf STDERR "%s\n",
                Qt4::DBusConnection::sessionBus()->lastError()->message();
        exit 1;
    }
    
    exit $app->exec();
}

main();
