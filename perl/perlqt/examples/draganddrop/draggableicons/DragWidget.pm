package DragWidget;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Frame );

# [0]
sub NEW {
    my ( $class, $parent ) = @_;
    $class->SUPER::NEW( $parent );

    this->setMinimumSize(200, 200);
    this->setFrameStyle(Qt4::Frame::Sunken() | Qt4::Frame::StyledPanel());
    this->setAcceptDrops(1);

    my $boatIcon = Qt4::Label(this);
    $boatIcon->setPixmap(Qt4::Pixmap('images/boat.png'));
    $boatIcon->move(20, 20);
    $boatIcon->show();
    $boatIcon->setAttribute(Qt4::WA_DeleteOnClose());

    my $carIcon = Qt4::Label(this);
    $carIcon->setPixmap(Qt4::Pixmap('images/car.png'));
    $carIcon->move(120, 20);
    $carIcon->show();
    $carIcon->setAttribute(Qt4::WA_DeleteOnClose());

    my $houseIcon = Qt4::Label(this);
    $houseIcon->setPixmap(Qt4::Pixmap('images/house.png'));
    $houseIcon->move(20, 120);
    $houseIcon->show();
    $houseIcon->setAttribute(Qt4::WA_DeleteOnClose());
}
# [0]

sub dragEnterEvent {
    my ($event) = @_;
    if ($event->mimeData()->hasFormat('application/x-dnditemdata')) {
        if ($event->source() == this) {
            $event->setDropAction(Qt4::MoveAction());
            $event->accept();
        } else {
            $event->acceptProposedAction();
        }
    } else {
        $event->ignore();
    }
}

sub dragMoveEvent {
    my ($event) = @_;
    if ($event->mimeData()->hasFormat('application/x-dnditemdata')) {
        if ($event->source() == this) {
            $event->setDropAction(Qt4::MoveAction());
            $event->accept();
        } else {
            $event->acceptProposedAction();
        }
    } else {
        $event->ignore();
    }
}

sub dropEvent {
    my ($event) = @_;
    if ($event->mimeData()->hasFormat('application/x-dnditemdata')) {
        my $itemData = $event->mimeData()->data('application/x-dnditemdata');
        my $dataStream = Qt4::DataStream($itemData, Qt4::IODevice::ReadOnly());
        
        my $pixmap = Qt4::Pixmap();
        my $offset = Qt4::Point();
        {
            no warnings qw(void); # For bitshift warning
            $dataStream >> $pixmap >> $offset;
        }

        my $newIcon = Qt4::Label(this);
        $newIcon->setPixmap($pixmap);
        $newIcon->move($event->pos() - $offset);
        $newIcon->show();
        $newIcon->setAttribute(Qt4::WA_DeleteOnClose());

        if ($event->source() == this) {
            $event->setDropAction(Qt4::MoveAction());
            $event->accept();
        } else {
            $event->acceptProposedAction();
        }
    } else {
        $event->ignore();
    }
}

# [1]
sub mousePressEvent {
    my ($event) = @_;
    my $child = this->childAt($event->pos());
    if (!$child) {
        return;
    }

    my $pixmap = $child->pixmap();

    my $itemData = Qt4::ByteArray();
    my $dataStream = Qt4::DataStream($itemData, Qt4::IODevice::WriteOnly());
    {
        no warnings qw(void); # For bitshift warning
        $dataStream << $pixmap << Qt4::Point($event->pos() - $child->pos());
    }
# [1]

# [2]
    my $mimeData = Qt4::MimeData();
    $mimeData->setData('application/x-dnditemdata', $itemData);
# [2]
        
# [3]
    my $drag = Qt4::Drag(this);
    $drag->setMimeData($mimeData);
    $drag->setPixmap($pixmap);
    $drag->setHotSpot($event->pos() - $child->pos());
# [3]

    # XXX Fix this.  Shared memory on the Pixmap (I think) causes $tempPixmap
    # and $pixmap to point to the same data.
    my $tempPixmap = $pixmap;
    my $painter = Qt4::Painter();
    $painter->begin($tempPixmap);
    $painter->fillRect($tempPixmap->rect(), Qt4::Color(127,127,127,127));
    $painter->end();

    $child->setPixmap($tempPixmap);

    my $result = $drag->exec(Qt4::CopyAction() | Qt4::MoveAction(), Qt4::CopyAction());
    if ($result == Qt4::MoveAction()) {
        $child->close();
    }
    else {
        $child->show();
        $child->setPixmap($pixmap);
    }
}

1;
