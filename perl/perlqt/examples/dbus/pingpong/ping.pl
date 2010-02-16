#!/usr/bin/perl

use strict;
use warnings;

use Qt4;
use Qt4::isa qw( Qt4::Object );

use PingCommon qw( SERVICE_NAME );

sub main {
    my $app = Qt4::Application(\@ARGV);

    if (!Qt4::DBusConnection::sessionBus()->isConnected()) {
        die "Cannot connect to the D-BUS session bus.\n" .
                "To start it, run:\n" .
                "\teval `dbus-launch --auto-syntax`\n";
    }

    my $iface = Qt4::DBusInterface(SERVICE_NAME, '/', '', Qt4::DBusConnection::sessionBus());
    if ($iface->isValid()) {
        my $reply = Qt4::DBusReply( $iface->call( 'ping', Qt4::Variant(@ARGV > 0 ? Qt4::String($ARGV[0]) : Qt4::String(''))) );
        if ($reply->isValid()) {
            printf "Reply was: %s\n", $reply->value();
            exit 0;
        }

        printf STDERR "Call failed: %s\n", $reply->error()->message();
        exit 1;
    }

    printf STDERR "%s\n",
            Qt4::DBusConnection::sessionBus()->lastError()->message();
    exit 1;
}

main();
