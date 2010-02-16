package LEDWidget;

use strict;
use warnings;

use Qt4;
use Qt4::isa qw( Qt4::Label );
use Qt4::slots
    flash => [],
    extinguish => [];

sub onPixmap() {
    return this->{onPixmap};
}

sub offPixmap() {
    return this->{offPixmap};
}

sub flashTimer() {
    return this->{flashTimer};
}

sub NEW {
    my ( $class, $parent ) = @_;
    $class->SUPER::NEW( $parent );
    this->{onPixmap} = Qt4::Pixmap('ledon.png');
    this->{offPixmap} = Qt4::Pixmap('ledoff.png');
    this->setPixmap(this->offPixmap());
    this->{flashTimer} = Qt4::Timer();
    this->flashTimer->setInterval(200);
    this->flashTimer->setSingleShot(1);
    this->connect(this->flashTimer, SIGNAL 'timeout()', this, SLOT 'extinguish()');
}

sub extinguish {
    this->setPixmap(this->offPixmap());
}

sub flash {
    this->setPixmap(this->onPixmap());
    this->flashTimer->start();
}

1;
