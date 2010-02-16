package TableModel;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw(Qt4::AbstractTableModel);

Qt4::_internal::installsignal( 'Qt4::AbstractTableModel::dataChanged' );

sub NEW {
    my ( $class, $pairs, $parent ) = @_;
    my $listOfPairs;
    if ( ref $pairs eq 'ARRAY' && defined $parent ) {
        $listOfPairs = $pairs;
    }
    else {
        $listOfPairs = [];
        $parent = $pairs;
    }

    $class->SUPER::NEW( $parent );
    this->{listOfPairs} = $listOfPairs;
}

sub rowCount {
    return scalar @{this->{listOfPairs}};
}

sub columnCount {
    return 2;
}

sub data {
    my ($index, $role) = @_;
    my $listOfPairs = this->{listOfPairs};
    if (!$index->isValid()) {
        return Qt4::Variant();
    }
    
    if ($index->row() >= scalar @{$listOfPairs} || $index->row() < 0) {
        return Qt4::Variant();
    }
    
    if ($role == Qt4::DisplayRole()) {
        my $pair = $listOfPairs->[$index->row()];
        
        if ($index->column() == 0) {
            return $pair->[0] ? Qt4::Variant($pair->[0]) : Qt4::Variant();
        }
        elsif ($index->column() == 1) {
            return $pair->[1] ? Qt4::Variant($pair->[1]) : Qt4::Variant();
        }
    }
    return Qt4::Variant();
}

sub headerData {
    my ($section, $orientation, $role) = @_;
    if ($role != Qt4::DisplayRole()) {
        return Qt4::Variant();
    }
    
    if ($orientation == Qt4::Horizontal()) {
        if ($section == 0) {
            return this->tr("Name");
        }
        elsif ($section == 1) {              
            return this->tr("Address");
        }
        else {
            return Qt4::Variant();
        }
    }
    return Qt4::Variant();
}

sub insertRows {
    my ($position, $rows, $index) = @_;
    my $listOfPairs = this->{listOfPairs};
    this->beginInsertRows(Qt4::ModelIndex(), $position, $position+$rows-1);
    
    foreach my $row (0..$rows-1) {
        if( $position == 0 ) {
            unshift @{$listOfPairs}, [ ' ', ' ' ];
        }
        elsif( $position == scalar @{$listOfPairs} ) {
            push @{$listOfPairs}, [ ' ', ' ' ];
        }
        else {
            #$listOfPairs->[$position] = [ ' ', ' ' ];
        }
    }

    this->endInsertRows();
    return 1;
}

sub removeRows {
    my ($position, $rows, $index) = @_;
    my $listOfPairs = this->{listOfPairs};
    this->beginRemoveRows(Qt4::ModelIndex(), $position, $position+$rows-1);

    foreach my $row (0..$rows-1) {
        splice( @{$listOfPairs}, $position, 1 );
    }

    this->endRemoveRows();
    return 1;
}

sub setData {
    my ($index, $value, $role) = @_;
    my $listOfPairs = this->{listOfPairs};
    if ($index->isValid() && $role == Qt4::EditRole()) {
        my $row = $index->row();

        my $p = $listOfPairs->[$row];

        if ($index->column() == 0) {
            $p->[0] = $value;
        }
        elsif ($index->column() == 1) {
            $p->[1] = $value;
        }
        else {
            return 0;
        }

        $listOfPairs->[$row] = $p;
        #Qt4::_internal::setDebug(0xffffff);
        emit dataChanged($index, $index);
        #Qt4::_internal::setDebug(0);

        return 1;
    }

    return 0;
}

sub flags {
    my ($index) = @_;
    if (!$index->isValid()) {
        return Qt4::ItemIsEnabled();
    }

    return bless( \this->SUPER::flags($index), 'Qt4::ItemFlag') | Qt4::ItemIsEditable();
}

sub getList {
    return this->{listOfPairs};
}

1;
