package CarAdaptor;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::DBusAbstractAdaptor );
use Qt4::classinfo
    'D-Bus Interface' => 'com.trolltech.Examples.CarInterface',
    'D-Bus Introspection' => '' .
"  <interface name=\'com.trolltech.Examples.CarInterface\' >\n" .
"    <method name=\'accelerate\' />\n" .
"    <method name=\'decelerate\' />\n" .
"    <method name=\'turnLeft\' />\n" .
"    <method name=\'turnRight\' />\n" .
"    <signal name=\'crashed\' />\n" .
"  </interface>\n" .
        '';
use Qt4::slots
    accelerate => [],
    decelerate => [],
    turnLeft => [],
    turnRight => [];
use Qt4::signals
    crashed => [];

sub NEW
{
    my ($class, $parent, $car) = @_;
    # constructor
    $class->SUPER::NEW($parent);
    this->{car} = $car;
    this->startTimer(1000 / 33);
}

sub accelerate
{
    # handle method call com.trolltech.Examples.CarInterface.accelerate
    #Qt4::MetaObject::invokeMethod(this->{car}, 'accelerate');
    this->{car}->accelerate();
}

sub decelerate
{
    # handle method call com.trolltech.Examples.CarInterface.decelerate
    #Qt4::MetaObject::invokeMethod(this->{car}, 'decelerate');
    this->{car}->decelerate();
}

sub turnLeft
{
    # handle method call com.trolltech.Examples.CarInterface.turnLeft
    #Qt4::MetaObject::invokeMethod(this->{car}, 'turnLeft');
    this->{car}->turnLeft();
}

sub turnRight
{
    # handle method call com.trolltech.Examples.CarInterface.turnRight
    #Qt4::MetaObject::invokeMethod(this->{car}, 'turnRight');
    this->{car}->turnRight();
}

sub timerEvent
{
    this->{car}->timerEvent(@_);
}

1;
