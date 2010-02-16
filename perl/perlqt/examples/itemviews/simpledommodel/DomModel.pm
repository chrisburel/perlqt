package DomModel;

use strict;
use warnings;
use Qt4;
# [0]
use Qt4::isa qw( Qt4::AbstractItemModel );
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
    this->setRootItem( DomItem->new(this->domDocument, 0) );
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
        return Qt4::Variant();
    }

    if ($role != Qt4::DisplayRole()) {
        return Qt4::Variant();
    }

    my $item = $index->internalPointer();

    my $node = $item->node();
# [3] //! [4]
    my $attributes = [];
    my $attributeMap = $node->attributes();

    if ($index->column() == 0) {
        return Qt4::Variant(Qt4::String($node->nodeName()));
    }
    elsif ($index->column() == 1) {
        return Qt4::Variant() unless $attributeMap->count();
        foreach my $i (0..$attributeMap->count()) {
            my $attribute = $attributeMap->item($i);
            my $nodeName = $attribute->nodeName();
            my $nodeValue = $attribute->nodeValue();
            $nodeName = $nodeName ? $nodeName : '';
            $nodeValue = $nodeValue ? $nodeValue : '';
            push @{$attributes}, $nodeName . '="'
                          .$nodeValue . '"';
        }
        return Qt4::Variant(Qt4::String(join ' ', @{$attributes}));
    }
    elsif ($index->column() == 2) {
        return Qt4::Variant() unless $node->nodeValue();
        return Qt4::Variant(Qt4::String(join ' ', split "\n", $node->nodeValue() ));
    }
    else {
        return Qt4::Variant();
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

    return Qt4::ItemIsEnabled() | Qt4::ItemIsSelectable();
}
# [5]

# [6]
sub headerData
{
    my ($section, $orientation, $role) = @_;
    if ($orientation == Qt4::Horizontal() && $role == Qt4::DisplayRole()) {
        if ($section == 0) {
            return Qt4::Variant(Qt4::String(this->tr('Name')));
        }
        elsif ($section == 1) {
            return Qt4::Variant(Qt4::String(this->tr('Attributes')));
        }
        elsif ($section == 2) {
            return Qt4::Variant(Qt4::String(this->tr('Value')));
        }
        else {
            return Qt4::Variant();
        }
    }

    return Qt4::Variant();
}
# [6]

# [7]
sub index
{
    my ($row, $column, $parent) = @_;
    if (!this->hasIndex($row, $column, $parent)) {
        return Qt4::ModelIndex();
    }

    my $parentItem = DomItem->new();

    if (!$parent->isValid()) {
        $parentItem = this->rootItem;
    }
    else {
        $parentItem = $parent->internalPointer();
    }
# [7]

# [8]
    my $childItem = $parentItem->child($row);
    if ($childItem) {
        my $ret = this->createIndex($row, $column, $childItem);
        return $ret;
    }
    else {
        return Qt4::ModelIndex();
    }
}
# [8]

# [9]
sub parent
{
    my ($child) = @_;
    return unless $child;
    if (!$child->isValid()) {
        return Qt4::ModelIndex();
    }

    my $childItem = $child->internalPointer();
    my $parentItem = $childItem->parent();

    if (!$parentItem || $parentItem == this->rootItem) {
        return Qt4::ModelIndex();
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

    my $parentItem = DomItem->new();

    if (!$parent->isValid()) {
        $parentItem = this->rootItem;
    }
    else {
        $parentItem = $parent->internalPointer();
    }

    return scalar $parentItem->node()->childNodes()->count();
}
# [10]

1;
