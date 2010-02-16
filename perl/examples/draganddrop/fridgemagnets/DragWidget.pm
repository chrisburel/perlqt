package DragWidget;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::Widget );
use DragLabel;
use List::Util qw(max);

# [0]
sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
    my $dictionaryFile = Qt4::File('words.txt');
    $dictionaryFile->open(Qt4::File::ReadOnly());
    my $inputStream = Qt4::TextStream($dictionaryFile);
# [0]

# [1]
    my $x = 5;
    my $y = 5;

    while (!$inputStream->atEnd()) {
        my $word;
        no warnings qw(void);
        $inputStream >> Qt4::String($word);
        use warnings;
        if ($word) {
            my $wordLabel = DragLabel($word, this);
            $wordLabel->move($x, $y);
            $wordLabel->show();
            $wordLabel->setAttribute(Qt4::WA_DeleteOnClose());
            $x += $wordLabel->width() + 2;
            if ($x >= 245) {
                $x = 5;
                $y += $wordLabel->height() + 2;
            }
        }
    }
# [1]

# [2]
    my $newPalette = this->palette();
    $newPalette->setColor(Qt4::Palette::Window(), Qt4::Color(Qt4::white()));
    this->setPalette($newPalette);

    this->setMinimumSize(400, max(200, $y));
    this->setWindowTitle(this->tr('Fridge Magnets'));
# [2] //! [3]
    this->setAcceptDrops(1);
}
# [3]

# [4]
sub dragEnterEvent
{
    my ($event) = @_;
# [4] //! [5]
    if ($event->mimeData()->hasFormat('application/x-fridgemagnet')) {
        my $children = this->children();
        if ($children && grep{ $_ eq $event->source } @{$children}) {
            $event->setDropAction(Qt4::MoveAction());
            $event->accept();
        } else {
            $event->acceptProposedAction();
# [5] //! [6]
        }
# [6] //! [7]
    } elsif ($event->mimeData()->hasText()) {
        $event->acceptProposedAction();
    } else {
        $event->ignore();
    }
}
# [7]

# [8]
sub dragMoveEvent
{
    my ($event) = @_;
    if ($event->mimeData()->hasFormat('application/x-fridgemagnet')) {
        my $children = this->children();
        if ($children && grep{ $_ eq $event->source } @{$children}) {
            $event->setDropAction(Qt4::MoveAction());
            $event->accept();
        } else {
            $event->acceptProposedAction();
        }
    } elsif ($event->mimeData()->hasText()) {
        $event->acceptProposedAction();
    } else {
        $event->ignore();
    }
}
# [8]

# [9]
sub dropEvent
{
    my ($event) = @_;
    if ($event->mimeData()->hasFormat('application/x-fridgemagnet')) {
        my $mime = $event->mimeData();
# [9] //! [10]
        my $itemData = $mime->data('application/x-fridgemagnet');
        my $dataStream = Qt4::DataStream($itemData, Qt4::IODevice::ReadOnly());

        my $text = '';
        my $offset = Qt4::Point();
        no warnings qw(void);
        $dataStream >> Qt4::String($text) >> $offset;
        use warnings;
# [10]
# [11]
        my $newLabel = DragLabel($text, this);
        $newLabel->move($event->pos() - $offset);
        $newLabel->show();
        $newLabel->setAttribute(Qt4::WA_DeleteOnClose());

        if ($event->source() == this) {
            $event->setDropAction(Qt4::MoveAction());
            $event->accept();
        } else {
            $event->acceptProposedAction();
        }
# [11] //! [12]
    } elsif ($event->mimeData()->hasText()) {
        my @pieces = split /\s+/, $event->mimeData()->text();
        my $position = $event->pos();

        foreach my $piece ( @pieces ) {
            my $newLabel = DragLabel($piece, this);
            $newLabel->move($position);
            $newLabel->show();
            $newLabel->setAttribute(Qt4::WA_DeleteOnClose());

            $position += Qt4::Point($newLabel->width(), 0);
        }

        $event->acceptProposedAction();
    } else {
        $event->ignore();
    }
}
# [12]

# [13]
sub mousePressEvent
{
    my ($event) = @_;
# [13]
# [14]
    my $child = this->childAt($event->pos());
    if (!$child) {
        return;
    }

    my $hotSpot = $event->pos() - $child->pos();

    my $itemData = Qt4::ByteArray();
    my $dataStream = Qt4::DataStream($itemData, Qt4::IODevice::WriteOnly());
    no warnings qw(void);
    $dataStream << Qt4::String($child->labelText()) << Qt4::Point($hotSpot);
    use warnings;
# [14]

# [15]
    my $mimeData = Qt4::MimeData();
    $mimeData->setData('application/x-fridgemagnet', $itemData);
    $mimeData->setText($child->labelText());
# [15]

# [16]
    my $drag = Qt4::Drag(this);
    $drag->setMimeData($mimeData);
    $drag->setPixmap($child->pixmap());
    $drag->setHotSpot($hotSpot);

    $child->hide();
# [16]

# [17]
    if ($drag->exec(Qt4::MoveAction() | Qt4::CopyAction(), Qt4::CopyAction()) == Qt4::MoveAction()) {
        $child->close();
    }
    else {
        $child->show();
    }
}
# [17]

1;
