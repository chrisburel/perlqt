package View;

use strict;
use warnings;
use Qt4;

use Qt4::isa qw( Qt4::GraphicsView );
use Qt4::slots
    updateImage => ['int', 'const QString &'];

use InformationWindow;
use ImageItem;

# [0]
sub NEW
{
    my ($class, $offices, $images, $parent) = @_;
    $class->SUPER::NEW( $parent );
    this->{officeTable} = Qt4::SqlRelationalTableModel(this);
    this->{officeTable}->setTable($offices);
    this->{officeTable}->setRelation(1, Qt4::SqlRelation($images, 'locationid', 'file'));
    this->{officeTable}->select();
# [0]

# [1]
    this->{scene} = Qt4::GraphicsScene(this);
    this->{scene}->setSceneRect(0, 0, 465, 615);
    this->setScene(this->{scene});

    this->addItems();

    my $logo = this->{scene}->addPixmap(Qt4::Pixmap('logo.png'));
    $logo->setPos(30, 515);

    this->setMinimumSize(470, 620);
    this->setMaximumSize(470, 620);

    this->setWindowTitle(this->tr('Offices World Wide'));
}
# [1]

# [3]
sub addItems
{
    my $officeCount = this->{officeTable}->rowCount();

    my $imageOffset = 150;
    my $leftMargin = 70;
    my $topMargin = 40;

    foreach my $i ( 0..$officeCount-1 ) {
        my $image;
        my $label;
        my $record = this->{officeTable}->record($i);

        my $id = $record->value('id')->toInt();
        my $file = $record->value('file')->toString();
        my $location = $record->value('location')->toString();

        my $columnOffset = (sprintf( '%d', ($i / 3)) * 37);
        my $x = (sprintf( '%d', ($i / 3)) * $imageOffset) + $leftMargin + $columnOffset;
        my $y = (sprintf( '%d', ($i % 3)) * $imageOffset) + $topMargin;

        $image = ImageItem($id, Qt4::Pixmap($file));
        $image->setData(0, Qt4::Variant(Qt4::Int($i)));
        $image->setPos($x, $y);
        this->{scene}->addItem($image);
        # XXX Remove this once Issue 22 is resolved.
        push @{this->{images}}, $image;

        $label = this->{scene}->addText($location);
        my $labelOffset = Qt4::PointF((150 - $label->boundingRect()->width()) / 2, 120.0);
        $label->setPos(Qt4::PointF($x, $y) + $labelOffset);
    }
}
# [3]

# [5]
sub mouseReleaseEvent
{
    my ($event) = @_;
    if (my $item = this->itemAt($event->pos())) {
        if ($item->isa('ImageItem')) {
            this->showInformation($item);
        }
    }
    this->SUPER::mouseReleaseEvent($event);
}
# [5]

# [6]
sub showInformation
{
    my ($image) = @_;
    my $id = $image->id();
    if ($id < 0 || $id >= this->{officeTable}->rowCount()) {
        return;
    }

    my $window = this->findWindow($id);
    if ($window && $window->isVisible()) {
        $window->raise();
        $window->activateWindow();
    } elsif ($window && !$window->isVisible()) {
        $window->show();
    } else {
        my $window = InformationWindow($id, this->{officeTable}, this);

        this->connect($window, SIGNAL 'imageChanged(int, QString)',
                this, SLOT 'updateImage(int, QString)');

        $window->move(this->pos() + Qt4::Point(20, 40));
        $window->show();
        push @{this->{informationWindows}}, $window;
    }
}
# [6]

# [7]
sub updateImage
{
    my ($id, $fileName) = @_;
    my $items = this->{scene}->items();

    foreach my $item (@{$items}) {
        if ($item->isa('ImageItem')) {
            my $image = $item;
            if ($image->id() == $id){
                $image->setPixmap(Qt4::Pixmap($fileName));
                $image->adjust();
                last;
            }
        }
    }
}
# [7]

# [8]
sub findWindow
{
    my ($id) = @_;
    foreach my $window ( @{this->{informationWindows}} ) {
        if ( $window->id() == $id ) {
            return $window;
        }
    }
    return;
}
# [8]

1;
