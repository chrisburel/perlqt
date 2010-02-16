package ColorListEditor;

use strict;
use warnings;
use Qt4;
# [0]
use Qt4::isa qw( Qt4::ComboBox );
#Q_PROPERTY(Qt4::Color color READ color WRITE setColor USER true)
# [0]

sub NEW
{
    my ( $class, $widget ) = @_;
    $class->SUPER::NEW( $widget );
    this->populateList();
}

# [0]
sub color
{
    return qVariantValue( this->itemData(this->currentIndex(), Qt4::DecorationRole()), 'Qt4::Color' );
}
# [0]

# [1]
sub setColor
{
    my ($color) = @_;
    this->setCurrentIndex(this->findData($color, ${Qt4::DecorationRole()}));
}
# [1]

# [2]
sub populateList
{
    my $colorNames = Qt4::Color::colorNames();

    foreach my $i (0..$#{$colorNames}) {
        my $color = Qt4::Color($colorNames->[$i]);

        this->insertItem($i, $colorNames->[$i]);
        this->setItemData($i, $color, Qt4::DecorationRole());
    }
}
# [2]

1;
