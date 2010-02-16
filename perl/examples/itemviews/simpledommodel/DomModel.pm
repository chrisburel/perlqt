package DomModel;

use strict;
use warnings;
use Qt;
# [0]
use Qt::isa qw( Qt::AbstractItemModel );
use DomItem;

sub domDocument() {
    return this->{domDocument};
}

sub setDomDocument($) {
    return this->{domDocument} = shift;
}

sub rootItem() {
    return this->{rootItem};
}

sub setRootItem($) {
    return this->{rootItem} = shift;
}

# [0]

# [0]
sub NEW {
    my ( $class, $document, $parent ) = @_;
    $class->SUPER::NEW( $parent );
    this->setDomDocument( $document );
    this->setRootItem( DomItem(this->domDocument, 0) );
}
# [0]

# [2]
sub columnCount
{
    return 3;
}
# [2]

# [3]
sub data
{
    my ($index, $role) = @_;
    if (!$index->isValid()) {
        return Qt::Variant();
    }

    if ($role != Qt::DisplayRole()) {
        return Qt::Variant();
    }

    my $item = CAST $index->internalPointer(), 'DomItem';

    my $node = $item->node();
# [3] //! [4]
    my $attributes = [];
    my $attributeMap = $node->attributes();

    if ($index->column() == 0) {
        return Qt::Variant($node->nodeName());
    }
    elsif ($index->column() == 1) {
        foreach my $i (0..$#{$attributeMap}) {
            my $attribute = $attributeMap->[$i];
            push @{$attributes}, $attribute->nodeName() . '="'
                          .$attribute->nodeValue() . '"';
        }
        return Qt::Variant(join ' ', @{$attributes});
    }
    elsif ($index->column() == 2) {
        return Qt::Variant( join ' ', split "\n", $node->nodeValue() );
    }
    else {
        return Qt::Variant();
    }
}
# [4]

# [5]
sub flags
{
    my ($index) = @_;
    if (!$index->isValid()) {
        return 0;
    }

    return Qt::ItemIsEnabled() | Qt::ItemIsSelectable();
}
# [5]

# [6]
sub headerData
{
    my ($section, $orientation, $role) = @_;
    if ($orientation == Qt::Horizontal() && $role == Qt::DisplayRole()) {
        if ($section == 0) {
            return Qt::Variant(this->tr('Name'));
        }
        elsif ($section == 1) {
            return Qt::Variant(this->tr('Attributes'));
        }
        elsif ($section == 2) {
            return Qt::Variant(this->tr('Value'));
        }
        else {
            return Qt::Variant();
        }
    }

    return Qt::Variant();
}
# [6]

# [7]
sub index
{
    my ($row, $column, $parent) = @_;
    if (!this->hasIndex($row, $column, $parent)) {
        return Qt::ModelIndex();
    }

    my $parentItem = DomItem();

    if (!$parent->isValid()) {
        $parentItem = this->rootItem;
    }
    else {
        $parentItem = CAST $parent->internalPointer(), 'DomItem';
    }
# [7]

# [8]
    my $childItem = $parentItem->child($row);
    if ($childItem) {
        return this->createIndex($row, $column, $childItem);
    }
    else {
        return Qt::ModelIndex();
    }
}
# [8]

# [9]
sub parent
{
    my ($child) = @_;
    if (!$child->isValid()) {
        return Qt::ModelIndex();
    }

    my $childItem = CAST $child->internalPointer(), 'DomItem';
    my $parentItem = CAST $childItem->parent(), 'DomItem';

    if (!$parentItem || $parentItem == this->rootItem) {
        return Qt::ModelIndex();
    }

    return this->createIndex($parentItem->row(), 0, $parentItem);
}
# [9]

# [10]
sub rowCount
{
    my ($parent) = @_;
    if ($parent->column() > 0) {
        return 0;
    }

    my $parentItem = DomItem();

    if (!$parent->isValid()) {
        $parentItem = this->rootItem;
    }
    else {
        $parentItem = CAST $parent->internalPointer(), 'DomItem';
    }

    return scalar @{$parentItem->node()->childNodes()};
}
# [10]

1;
