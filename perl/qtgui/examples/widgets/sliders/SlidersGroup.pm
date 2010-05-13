package SlidersGroup;

use strict;
use warnings;
use blib;

use Qt4;
# [0]
use Qt4::isa qw( Qt4::GroupBox );
use Qt4::signals
    valueChanged => ['int'];
use Qt4::slots
    setValue => ['int'],
    setMinimum => ['int'],
    setMaximum => ['int'],
    invertAppearance => ['bool'],
    invertKeyBindings => ['bool'];

sub slider() {
    return this->{slider};
}

sub scrollBar() {
    return this->{scrollBar};
}

sub dial() {
    return this->{dial};
}
# [0]

# [0]
sub NEW {
    my ( $class, $orientation, $title, $parent) = @_;
    $class->SUPER::NEW( $title, $parent );
    my $slider = this->{slider} = Qt4::Slider($orientation);
    $slider->setFocusPolicy(Qt4::StrongFocus());
    $slider->setTickPosition(Qt4::Slider::TicksBothSides());
    $slider->setTickInterval(10);
    $slider->setSingleStep(1);

    my $scrollBar = this->{scrollBar} =  Qt4::ScrollBar($orientation);
    $scrollBar->setFocusPolicy(Qt4::StrongFocus());

    my $dial = this->{dial} = Qt4::Dial();
    $dial->setFocusPolicy(Qt4::StrongFocus());

    this->connect($slider, SIGNAL 'valueChanged(int)', $scrollBar, SLOT 'setValue(int)');
    this->connect($scrollBar, SIGNAL 'valueChanged(int)', $dial, SLOT 'setValue(int)');
    this->connect($dial, SIGNAL 'valueChanged(int)', $slider, SLOT 'setValue(int)');
# [0] //! [1]
    this->connect($dial, SIGNAL 'valueChanged(int)', this, SIGNAL 'valueChanged(int)');
# [1] //! [2]

# [2] //! [3]
    my $direction;
# [3] //! [4]

    if ($orientation == Qt4::Horizontal()) {
        $direction = Qt4::BoxLayout::TopToBottom();
    }
    else {
        $direction = Qt4::BoxLayout::LeftToRight();
    }

    my $slidersLayout = Qt4::BoxLayout($direction);
    $slidersLayout->addWidget($slider);
    $slidersLayout->addWidget($scrollBar);
    $slidersLayout->addWidget($dial);
    this->setLayout($slidersLayout);
}
# [4]

# [5]
sub setValue {
# [5] //! [6]
    my ($value) = @_;
    this->slider->setValue($value);
}
# [6]

# [7]
sub setMinimum {
# [7] //! [8]
    my ($value) = @_;
    this->slider->setMinimum($value);
    this->scrollBar->setMinimum($value);
    this->dial->setMinimum($value);
}
# [8]

# [9]
sub setMaximum {
# [9] //! [10]
    my ($value) = @_;
    this->slider->setMaximum($value);
    this->scrollBar->setMaximum($value);
    this->dial->setMaximum($value);
}
# [10]

# [11]
sub invertAppearance {
# [11] //! [12]
    my ($invert) = @_;
    this->slider->setInvertedAppearance($invert);
    this->scrollBar->setInvertedAppearance($invert);
    this->dial->setInvertedAppearance($invert);
}
# [12]

# [13]
sub invertKeyBindings {
# [13] //! [14]
    my ($invert) = @_;
    this->slider->setInvertedControls($invert);
    this->scrollBar->setInvertedControls($invert);
    this->dial->setInvertedControls($invert);
}
# [14]

1;
