package Button;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::ToolButton );

use List::Util qw(max);

# [0]
sub NEW {
    my ( $class, $text, $parent ) = @_;
    $class->SUPER::NEW( $parent );
    this->setSizePolicy(Qt4::SizePolicy::Expanding(), Qt4::SizePolicy::Preferred());
    this->setText($text);
}
# [0]

# [1]
sub sizeHint {
# [1] //! [2]
    my $size = this->SUPER::sizeHint();
    $size->setHeight( $size->height() + 20 );
    $size->setWidth( max($size->width(), $size->height()));
    return Qt4::Size($size);
}

# [2]

1;
