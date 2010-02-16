#!/usr/bin/perl

package Pong;

use strict;
use warnings;

use Qt4;
use Qt4::isa qw( Qt4::Object );
use Qt4::slots
    'QString ping' => ['QString'];

sub NEW {
    shift->SUPER::NEW(@_);
}

sub ping {
    my ( $arg ) = @_;
    Qt4::MetaObject::invokeMethod(Qt4::CoreApplication::instance(), 'quit');
    return "ping(\"$arg\") got called";
}

package main;

use strict;
use warnings;
use blib;

use Qt4;
use Pong;
use PingCommon qw( SERVICE_NAME );

sub main {
    my $app = Qt4::Application(\@ARGV);

    if (!Qt4::DBusConnection::sessionBus()->isConnected()) {
        die "Cannot connect to the D-BUS session bus.\n" .
                "To start it, run:\n" .
                "\teval `dbus-launch --auto-syntax`\n";
    }

    if (!Qt4::DBusConnection::sessionBus()->registerService(SERVICE_NAME)) {
        die Qt4::DBusConnection::sessionBus()->lastError()->message();
        exit(1);
    }

    my $pong = Pong();
    Qt4::DBusConnection::sessionBus()->registerObject('/', $pong, Qt4::DBusConnection::ExportAllSlots());
    
    exit $app->exec();
}

main();
