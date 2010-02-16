package LCDRange;

use strict;
use warnings;
use blib;

use Qt;
use Qt::isa qw(Qt::Widget);
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
    my $lcd = Qt::LCDNumber(2);
    $lcd->setSegmentStyle(Qt::LCDNumber::Filled());

    my $slider = Qt::Slider(Qt::Horizontal());
    $slider->setRange(0, 99);
    $slider->setValue(0);
    my $label = Qt::Label();

    $label->setAlignment(Qt::AlignHCenter() | Qt::AlignTop());
    $label->setSizePolicy(Qt::SizePolicy::Preferred(), Qt::SizePolicy::Fixed());

    this->connect($slider, SIGNAL "valueChanged(int)",
                  $lcd, SLOT "display(int)");
    this->connect($slider, SIGNAL "valueChanged(int)",
                  this, SIGNAL "valueChanged(int)");

    my $layout = Qt::VBoxLayout;
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
