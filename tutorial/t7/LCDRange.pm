package LCDRange;

use strict;
use warnings;
use blib;

use Qt;
use Qt::isa qw(Qt::QWidget);

sub NEW {
    shift->SUPER::NEW(@_);

    my $lcd = Qt::QLCDNumber(2);

    my $slider = Qt::QSlider(Qt::Qt::Horizontal());
    $slider->setRange(0, 99);
    $slider->setValue(0);

    this->connect($slider, SIGNAL "valueChanged(int)",
                  $lcd, SLOT "display(int)");
    this->connect($slider, SIGNAL "valueChanged(int)",
                  this, SIGNAL "valueChanged(int)");

    my $layout = Qt::QVBoxLayout;
    $layout->addWidget($lcd);
    $layout->addWidget($slider);
    this->setLayout($layout);
    this->{slider} = $slider;
}

sub value {
    return this->{slider}->value();
}

sub setValue {
    my ( $value ) = @_;
    this->{slider}->setValue($value);
}

1;
