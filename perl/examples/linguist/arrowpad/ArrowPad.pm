package ArrowPad;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::Widget );

sub upButton() {
    return this->{upButton};
}

sub downButton() {
    return this->{downButton};
}

sub leftButton() {
    return this->{leftButton};
}

sub rightButton() {
    return this->{rightButton};
}

sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW( $parent );
# [0]
    this->{upButton} = Qt4::PushButton(ArrowPad::tr("&Up"));
# [0] //! [1]
    this->{downButton} = Qt4::PushButton(ArrowPad::tr("&Down"));
# [1] //! [2]
    this->{leftButton} = Qt4::PushButton(ArrowPad::tr("&Left"));
# [2] //! [3]
    this->{rightButton} = Qt4::PushButton(ArrowPad::tr("&Right"));
# [3]

    my $mainLayout = Qt4::GridLayout();
    $mainLayout->addWidget(this->upButton, 0, 1);
    $mainLayout->addWidget(this->leftButton, 1, 0);
    $mainLayout->addWidget(this->rightButton, 1, 2);
    $mainLayout->addWidget(this->downButton, 2, 1);
    this->setLayout($mainLayout);
}

1;
