package LCDRange;

use strict;
use warnings;
use blib;

use Qt;
use Qt::isa qw(Qt::QWidget);
use Qt::slots setValue => ['int'],
              setRange => ['int', 'int'];
use Qt::signals valueChanged => ['int'];

sub NEW {
    shift->SUPER::NEW(@_);

    my $lcd = Qt::QLCDNumber(2);
    $lcd->setSegmentStyle(Qt::QLCDNumber::Filled());

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

    this->setFocusProxy($slider);

    this->{slider} = $slider;
}

sub value {
    return this->{slider}->value();
}

sub setValue {
    my ( $value ) = @_;
    this->{slider}->setValue($value);
}

sub setRange {
    my ( $minValue, $maxValue ) = @_;
    if (($minValue < 0) || ($maxValue > 99) || ($minValue > $maxValue)) {
        Qt::qWarning("LCDRange::setRange(%d, %d)\n" .
                     "\tRange must be 0..99\n" .
                     "\tand minValue must not be greater than maxValue",
                     $minValue, $maxValue);
        return;
    }
    this->{slider}->setRange($minValue, $maxValue);
}

1;
