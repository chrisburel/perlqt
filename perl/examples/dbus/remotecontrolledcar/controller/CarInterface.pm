package CarInterface;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::DBusAbstractInterface );

sub staticInterfaceName {
    return 'com.trolltech.Examples.CarInterface';
}

use Qt4::slots
    accelerate => [],
    decelerate => [],
    turnLeft => [],
    turnRight => [];

use Qt4::signals
    crashed => [];

sub NEW
{
    my ($class, $service, $path, $connection, $parent) = @_;
    $class->SUPER::NEW($service, $path, staticInterfaceName(), $connection, $parent);
}

sub accelerate
{
    return this->callWithArgumentList(Qt4::DBus::Block(), 'accelerate', []);
}

sub decelerate()
{
    return this->callWithArgumentList(Qt4::DBus::Block(), 'decelerate', []);
}

sub turnLeft()
{
    return this->callWithArgumentList(Qt4::DBus::Block(), 'turnLeft', []);
}

sub turnRight()
{
    return this->callWithArgumentList(Qt4::DBus::Block(), 'turnRight', []);
}

1;
