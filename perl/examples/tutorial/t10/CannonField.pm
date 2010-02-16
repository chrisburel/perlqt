package CannonField;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw(Qt4::Widget);
use Qt4::slots setAngle => ['int'],
              setForce => ['int'];
use Qt4::signals angleChanged => ['int'],
                forceChanged => ['int'];

sub NEW {
    shift->SUPER::NEW(@_);

    this->{currentAngle} = 45;
    this->{currentForce} = 0;
    this->setPalette(Qt4::Palette(Qt4::Color(250,250,200)));
    this->setAutoFillBackground(1);
}

sub setAngle {
    my ( $angle ) = @_;
    if ($angle < 5) {
        $angle = 5;
    }
    if ($angle > 70) {
        $angle = 70;
    }
    if (this->{currentAngle} == $angle) {
        return;
    }
    this->{currentAngle} = $angle;
    this->update(this->cannonRect());
    this->update();
    emit angleChanged( this->{currentAngle} );
}

sub setForce {
    my ( $force ) = @_;
    if ($force < 0) {
        $force = 0;
    }
    if (this->{currentForce} == $force) {
        return;
    }
    this->{currentForce} = $force;
    this->emit( 'forceChanged', this->{currentForce} );
}

sub paintEvent {
    my $painter = Qt4::Painter(this);

    $painter->setPen(Qt4::NoPen());
    $painter->setBrush(Qt4::Brush(Qt4::blue()));

    $painter->translate(0, this->rect()->height());
    $painter->drawPie(Qt4::Rect(-35, -35, 70, 70), 0, 90 * 16);
    $painter->rotate(-(this->{currentAngle}));
    $painter->drawRect(Qt4::Rect(30, -5, 20, 10));
    $painter->end();
}

sub cannonRect {
    my $result = Qt4::Rect(0, 0, 50, 50);
    $result->moveBottomLeft(this->rect()->bottomLeft());
    return $result;
}

1;
