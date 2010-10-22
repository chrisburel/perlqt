#!/usr/bin/perl

package MyWidget;

use strict;
use warnings;
use QtCore4;
use QtGui4;
use QtCore4::isa qw( Qt::Widget );
use QtCore4::signals
    doCoolStuff => ['int'];

sub NEW {
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
}

sub doStuff {
    doCoolStuff(1);
    doCoolStuff(2);
    doCoolStuff(3);
    doCoolStuff(4);
    doCoolStuff(5);
    doCoolStuff(6);
}

package main;

use strict;
use warnings;
use QtCore4;
use QtGui4;
use QtTest4;
use MyWidget;

use Test::More tests => 4;

my $app = Qt::Application(\@ARGV);
my $box = Qt::CheckBox( undef );
my $spy = Qt::SignalSpy($box, SIGNAL 'clicked(bool)');

$box->click();

is(scalar @{$spy}, 1);
my $arguments = shift @{$spy}; # take the first signal

is($arguments->[0]->toBool(), 1);

my $widget = MyWidget();
$spy = Qt::SignalSpy($widget, SIGNAL 'doCoolStuff(int)');
$widget->doStuff();
is(scalar @{$spy}, 6);
is_deeply( [map($_->[0]->toInt(), @{$spy})],
           [1, 2, 3, 4, 5, 6],
           'Spy Perl signals' );
