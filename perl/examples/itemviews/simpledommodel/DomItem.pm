package DomItem;

use strict;
use warnings;
use Qt;
# [0]
sub domNode() {
    return shift->{domNode};
}

sub setDomNode($) {
    return shift->{domNode} = shift;
}

sub childItems() {
    return shift->{childItems};
}

sub setChildItems($) {
    return shift->{childItems} = shift;
}

sub parentItem() {
    return shift->{parentItem};
}

sub setParentItem($) {
    return shift->{parentItem} = shift;
}

sub rowNumber() {
    return shift->{rowNumber};
}

sub setRowNumber($) {
    return shift->{rowNumber} = shift;
}
# [0]

# [0]
sub new
{
    my ($class, $node, $row, $parent) = @_;
    my $self = bless {}, $class;
    $self->setDomNode( $node );
# [0]
    # Record the item's location within its parent.
# [1]
    $self->setRowNumber( $row );
    $self->setParentItem( $parent );
    $self->setChildItems( {} );
    return $self;
}
# [1]

# [3]
sub node
{
    my ( $self ) = @_;
    return $self->domNode;
}
# [3]

# [4]
sub parent
{
    my ( $self ) = @_;
    return $self->parentItem;
}
# [4]

# [5]
sub child
{
    my ( $self, $i ) = @_;
    if (defined $self->childItems->{$i}) {
        return $self->childItems->{$i};
    }

    if ($i >= 0 && $i < scalar @{$self->domNode->childNodes()}) {
        my $childNode = $self->domNode->childNodes()->[$i];
        my $childItem = DomItem->new($childNode, $i, $self);
        $self->childItems->{$i} = $childItem;
        return $childItem;
    }
    return 0;
}
# [5]

# [6]
sub row
{
    my ( $self ) = @_;
    return $self->rowNumber;
}
# [6]

1;
