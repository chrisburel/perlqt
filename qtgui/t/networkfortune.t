#!/usr/bin/perl

package NetworkFortuneTest;

use strict;
use warnings;

use QtCore4;
use QtGui4;
use QtTest4 qw( QVERIFY );
use Server;
use lib '../fortuneclient';
use Client;
use QtCore4::isa qw(Qt::Object);
use QtCore4::slots
    initTestCase => [],
    getFortune =>[];
use Test::More;

sub NEW {
    my ($class, $parent) = @_;
    $class->SUPER::NEW();
}

sub getFortune {
    my $server = this->{server};
    my $client = this->{client};

    Qt::Test::keyClicks(
        $client->portLineEdit(),
        $server->tcpServer()->serverPort(),
        Qt::NoModifier()
    );

    foreach (0..30) {
        Qt::Test::keyClick(
            $client->getFortuneButton(),
            Qt::Key_Enter(),
            Qt::NoModifier(),
            20
        );
    }

    pass( 'Typing' );
}

sub initTestCase {
    my $server = Server();
    $server->show();
    Qt::Test::qWaitForWindowShown( $server );
    this->{server} = $server;

    my $client = Client();
    $client->show();
    Qt::Test::qWaitForWindowShown( $client );
    this->{client} = $client;

    pass( 'Window shown' );
}

package main;

use strict;
use warnings;

use QtCore4;
use QtGui4;
use QtTest4 qw(QTEST_MAIN);
use NetworkFortuneTest;
use Test::More tests => 2;

exit QTEST_MAIN('NetworkFortuneTest');
