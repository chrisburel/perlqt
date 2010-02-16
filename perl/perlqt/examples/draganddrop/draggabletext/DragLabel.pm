package DragLabel;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::Label );

sub NEW
{
    my ($class, $text, $parent) = @_;
    $class->SUPER::NEW( $text, $parent );
    this->setAutoFillBackground(1);
    this->setFrameShape(Qt4::Frame::Panel());
    this->setFrameShadow(Qt4::Frame::Raised());
}

1;
