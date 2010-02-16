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
    my( $class, $parent, $text ) = @_;
    $class->SUPER::NEW($parent);

    init();

    if( $text ) {
        setText($text);
    }
}

sub init {
    my $lcd = Qt::QLCDNumber(2);
    $lcd->setSegmentStyle(Qt::QLCDNumber::Filled());

    my $slider = Qt::QSlider(Qt::Qt::Horizontal());
    $slider->setRange(0, 99);
    $slider->setValue(0);
    my $label = Qt::QLabel();
    $label->setAlignment(Qt::Qt::AlignHCenter() | Qt::Qt::AlignTop());
    $label->setSizePolicy(Qt::QSizePolicy::Preferred(), Qt::QSizePolicy::Fixed());

    this->connect($slider, SIGNAL "valueChanged(int)",
                  $lcd, SLOT "display(int)");
    this->connect($slider, SIGNAL "valueChanged(int)",
                  this, SIGNAL "valueChanged(int)");

    my $layout = Qt::QVBoxLayout;
    $layout->addWidget($lcd);
    $layout->addWidget($slider);
    $layout->addWidget($label);
    this->setLayout($layout);

    this->setFocusProxy($slider);

    this->{slider} = $slider;
    this->{label} = $label;
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

sub setText {
    my ( $text ) = @_;
    this->{label}->setText($text);
}

1;
