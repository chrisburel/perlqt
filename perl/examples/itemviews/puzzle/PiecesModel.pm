package PiecesModel;

use strict;
use warnings;
use List::Util qw( min max );
use Qt4;
use Qt4::isa qw( Qt4::AbstractListModel );

use constant { RAND_MAX => 2147483647 };

sub locations() {
    return this->{locations};
}

sub pixmaps() {
    return this->{pixmaps};
}

sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW( $parent );

    this->{locations} = [];
    this->{pixmaps} = [];
}

sub data
{
    my ($index, $role) = @_;
    if (!$index->isValid()) {
        return Qt4::Variant();
    }

    if ($role == Qt4::DecorationRole()) {
        return Qt4::qVariantFromValue(Qt4::Icon(this->pixmaps->[$index->row()]->scaled(60, 60,
                         Qt4::KeepAspectRatio(), Qt4::SmoothTransformation())));
    }
    elsif ($role == Qt4::UserRole()) {
        return Qt4::qVariantFromValue(this->pixmaps->[$index->row()]);
    }
    elsif ($role == Qt4::UserRole() + 1) {
        return Qt4::Variant(this->locations->[$index->row()]);
    }

    return Qt4::Variant();
}

sub addPiece
{
    my ($pixmap, $location) = @_;
    my $row;
    if (int(2.0*rand(RAND_MAX)/(RAND_MAX+1.0)) == 1) {
        $row = 0;
    }
    else {
        $row = scalar @{this->pixmaps};
    }

    this->beginInsertRows(Qt4::ModelIndex(), $row, $row);
    splice @{this->pixmaps}, $row, 0, $pixmap;
    splice @{this->locations}, $row, 0, $location;
    this->endInsertRows();
}

sub flags
{
    my ($index) = @_;
    if ($index->isValid()) {
        return (Qt4::ItemIsEnabled() | Qt4::ItemIsSelectable() | Qt4::ItemIsDragEnabled());
    }

    return Qt4::ItemIsDropEnabled();
}

sub removeRows
{
    my ($row, $count, $parent) = @_;
    if ($parent->isValid()) {
        return 0;
    }

    if ($row >= scalar @{this->pixmaps} || $row + $count <= 0) {
        return 0;
    }

    my $beginRow = max(0, $row);
    my $endRow = min($row + $count - 1, scalar @{this->pixmaps} - 1);

    this->beginRemoveRows($parent, $beginRow, $endRow);

    while ($beginRow <= $endRow) {
        splice @{this->pixmaps}, $beginRow, 1;
        splice @{this->locations}, $beginRow, 1;
        ++$beginRow;
    }

    this->endRemoveRows();
    return 1;
}

sub mimeTypes
{
    return [ 'image/x-puzzle-piece' ];
}

sub mimeData
{
    my ($indexes) = @_;
    my $mimeData = Qt4::MimeData();
    my $encodedData = Qt4::ByteArray();

    my $stream = Qt4::DataStream($encodedData, Qt4::IODevice::WriteOnly());

    foreach my $index ( @{$indexes} ) {
        if ($index->isValid()) {
            my $pixmap = Qt4::qVariantValue( this->data($index, Qt4::UserRole()), 'Qt4::Pixmap' );
            my $location = this->data($index, Qt4::UserRole()+1)->toPoint();
            no warnings qw(void); # Ignore bitshift warning
            $stream << $pixmap << $location;
            use warnings;
        }
    }

    $mimeData->setData('image/x-puzzle-piece', $encodedData);
    return $mimeData;
}

sub dropMimeData
{
    my ($data, $action, $row, $column, $parent) = @_;
    if (!$data->hasFormat('image/x-puzzle-piece')) {
        return 0;
    }

    if ($action == Qt4::IgnoreAction()) {
        return 1;
    }

    if ($column > 0) {
        return 0;
    }

    my $endRow;

    if (!$parent->isValid()) {
        if ($row < 0) {
            $endRow = scalar @{this->pixmaps};
        }
        else {
            $endRow = min($row, scalar @{this->pixmaps});
        }
    } else {
        $endRow = $parent->row();
    }

    my $encodedData = $data->data('image/x-puzzle-piece');
    my $stream = Qt4::DataStream($encodedData, Qt4::IODevice::ReadOnly());

    while (!$stream->atEnd()) {
        my $pixmap = Qt4::Pixmap();
        my $location = Qt4::Point();
        no warnings qw(void); # Ignore bitshift warning
        $stream >> $pixmap >> $location;
        use warnings;

        this->beginInsertRows(Qt4::ModelIndex(), $endRow, $endRow);
        splice @{this->pixmaps}, $endRow, 0, $pixmap;
        splice @{this->locations}, $endRow, 0, $location;
        this->endInsertRows();

        ++$endRow;
    }

    return 1;
}

sub rowCount
{
    my ($parent) = @_;
    if ($parent->isValid()) {
        return 0;
    }
    else {
        return scalar @{this->pixmaps};
    }
}

sub supportedDropActions
{
    return Qt4::CopyAction() | Qt4::MoveAction();
}

sub addPieces
{
    my ($pixmap) = @_;
    this->beginRemoveRows(Qt4::ModelIndex(), 0, 24);
    this->{pixmaps} = [];
    this->{locations} = [];
    this->endRemoveRows();
    foreach my $y (0..4) {
        foreach my $x (0..4) {
            my $pieceImage = $pixmap->copy($x*80, $y*80, 80, 80);
            this->addPiece($pieceImage, Qt4::Point($x, $y));
        }
    }
}

1;
