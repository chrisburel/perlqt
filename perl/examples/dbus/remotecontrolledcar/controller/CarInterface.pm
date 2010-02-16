package CarInterface;

use strict;
use warnings;
use Qt;
use Qt::isa qw( Qt::DBusAbstractInterface );

sub staticInterfaceName {
    return 'com.trolltech.Examples.CarInterface';
}

use Qt::slots
    accelerate => [],
    decelerate => [],
    turnLeft => [],
    turnRight => [];

use Qt::signals
    crashed => [];

sub NEW
{
    my ($class, $service, $path, $connection, $parent) = @_;
    $class->SUPER::NEW($service, $path, staticInterfaceName(), $connection, $parent);
}

sub accelerate
{
    return this->callWithArgumentList(Qt::DBus::Block(), 'accelerate', []);
}

sub decelerate()
{
    return this->callWithArgumentList(Qt::DBus::Block(), 'decelerate', []);
}

sub turnLeft()
{
    return this->callWithArgumentList(Qt::DBus::Block(), 'turnLeft', []);
}

sub turnRight()
{
    return this->callWithArgumentList(Qt::DBus::Block(), 'turnRight', []);
}

1;
