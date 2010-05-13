package SortingBox;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Widget );

use ShapeItem;

# [0]
use Qt4::slots
    createNewCircle => [],
    createNewSquare => [],
    createNewTriangle => [];
# [0]

# [2]
sub shapeItems() {
    return this->{shapeItems};
}

sub circlePath() {
    return this->{circlePath};
}

sub squarePath() {
    return this->{squarePath};
}

sub trianglePath() {
    return this->{trianglePath};
}

sub previousPosition() {
    return this->{previousPosition};
}

sub itemInMotion() {
    return this->{itemInMotion};
}

sub newCircleButton() {
    return this->{newCircleButton};
}

sub newSquareButton() {
    return this->{newSquareButton};
}

sub newTriangleButton() {
    return this->{newTriangleButton};
}
# [2]

# [0]
sub NEW {
    my ( $class ) = @_;
    $class->SUPER::NEW();
# [0] //! [1]
    this->setMouseTracking(1);
# [1] //! [2]
    this->setBackgroundRole(Qt4::Palette::Base());
# [2]

    this->{itemInMotion} = 0;

    this->{circlePath} = Qt4::PainterPath();
    this->{squarePath} = Qt4::PainterPath();
    this->{trianglePath} = Qt4::PainterPath();
    this->{shapeItems} = [];

# [3]
    this->{newCircleButton} = createToolButton(this->tr('New Circle'),
                                       Qt4::Icon('images/circle.png'),
                                       SLOT 'createNewCircle()');

    this->{newSquareButton} = createToolButton(this->tr('New Square'),
                                       Qt4::Icon('images/square.png'),
                                       SLOT 'createNewSquare()');

    this->{newTriangleButton} = createToolButton(this->tr('New Triangle'),
                                         Qt4::Icon('images/triangle.png'),
                                         SLOT 'createNewTriangle()');

    this->circlePath->addEllipse(Qt4::RectF(0, 0, 100, 100));
    this->squarePath->addRect(Qt4::RectF(0, 0, 100, 100));

    my $x = this->trianglePath->currentPosition()->x();
    my $y = this->trianglePath->currentPosition()->y();
    this->trianglePath->moveTo($x + 120 / 2, $y);
    this->trianglePath->lineTo(0, 100);
    this->trianglePath->lineTo(120, 100);
    this->trianglePath->lineTo($x + 120 / 2, $y);

# [3] //! [4]
    this->setWindowTitle(this->tr('Tool Tips'));
    this->resize(500, 300);

    this->createShapeItem(circlePath, this->tr('Circle'), this->initialItemPosition(this->circlePath),
                    this->initialItemColor());
    this->createShapeItem(squarePath, this->tr('Square'), this->initialItemPosition(this->squarePath),
                    this->initialItemColor());
    this->createShapeItem(trianglePath, this->tr('Triangle'),
                    this->initialItemPosition(this->trianglePath), this->initialItemColor());
}
# [4]

# [5]
sub event {
# [5] //! [6]
    my ($event) = @_;
    if ($event->type() == Qt4::Event::ToolTip()) {
        my $helpEvent = CAST $event, 'Qt4::HelpEvent';
        my $index = this->itemAt($helpEvent->pos());
        if ($index != -1) {
            Qt4::ToolTip::showText($helpEvent->globalPos(), this->shapeItems->[$index]->toolTip());
        } else {
            Qt4::ToolTip::hideText();
            $event->ignore();
        }

        return 1;
    }
    return this->SUPER::event($event);
}
# [6]

# [7]
sub resizeEvent {
    # TODO figure out why the 1 and 2 argument form aren't correct in smoke.
    my $margin = this->style()->pixelMetric(Qt4::Style::PM_DefaultTopLevelMargin(), undef, undef);
    my $x = this->width() - $margin;
    my $y = this->height() - $margin;

    $y = this->updateButtonGeometry(this->newCircleButton, $x, $y);
    $y = this->updateButtonGeometry(this->newSquareButton, $x, $y);
    this->updateButtonGeometry(this->newTriangleButton, $x, $y);
}
# [7]

# [8]
sub paintEvent {
    my $painter = Qt4::Painter(this);
    $painter->setRenderHint(Qt4::Painter::Antialiasing());
    foreach my $shapeItem (@{this->{shapeItems}}) {
# [8] //! [9]
        $painter->translate($shapeItem->position());
# [9] //! [10]
        $painter->setBrush(Qt4::Brush($shapeItem->color()));
        $painter->drawPath($shapeItem->path());
        $painter->translate(-$shapeItem->position());
    }
    $painter->end();
}
# [10]

# [11]
sub mousePressEvent {
    my ($event) = @_;
    CAST $event, 'Qt4::MouseEvent';
    if ($event->button() == Qt4::LeftButton()) {
        my $index = this->itemAt($event->pos());
        if ($index != -1) {
            this->{itemInMotion} = this->shapeItems->[$index];
            this->{previousPosition} = $event->pos();
            push @{this->shapeItems}, splice @{this->shapeItems}, $index, 1;
            this->update();
        }
    }
}
# [11]

# [12]
sub mouseMoveEvent {
    my ($event) = @_;
    CAST $event, 'Qt4::MouseEvent';
    if (($event->buttons() & ${Qt4::LeftButton()}) && this->itemInMotion) {
        this->moveItemTo($event->pos());
    }
}
# [12]

# [13]
sub mouseReleaseEvent {
    my ($event) = @_;
    CAST $event, 'Qt4::MouseEvent';
    if ($event->button() == ${Qt4::LeftButton()} && this->itemInMotion) {
        this->moveItemTo($event->pos());
        this->{itemInMotion} = 0;
    }
}
# [13]

# [14]
my $circleCount = 1;
sub createNewCircle {
    this->createShapeItem(this->circlePath,
        sprintf( this->tr('Circle <%d>'), ++$circleCount ),
        this->randomItemPosition(), this->randomItemColor());
}
# [14]

# [15]
my $squareCount = 1;
sub createNewSquare {
    this->createShapeItem(this->squarePath,
        sprintf( this->tr('Square <%d>'), ++$squareCount ),
        this->randomItemPosition(), this->randomItemColor());
}
# [15]

# [16]
my $triangleCount = 1;
sub createNewTriangle {
    this->createShapeItem(trianglePath,
        sprintf( this->tr('Triangle <%d>'), ++$triangleCount ),
        this->randomItemPosition(), this->randomItemColor());
}
# [16]

# [17]
sub itemAt {
    my ($pos) = @_;
    foreach my $i ( reverse 0..$#{this->shapeItems} ) {
        my $item = this->shapeItems->[$i];
        if ($item->path()->contains(Qt4::PointF($pos - $item->position()))) {
            return $i;
        }
    }
    return -1;
}
# [17]

# [18]
sub moveItemTo {
    my ($pos) = @_;
    my $offset = $pos - this->previousPosition;
    this->itemInMotion->setPosition(this->itemInMotion->position() + $offset);
# [18] //! [19]
    this->{previousPosition} = $pos;
    this->update();
}
# [19]

# [20]
sub updateButtonGeometry {
    my ($button, $x, $y) = @_;
    my $size = $button->sizeHint();
    $button->setGeometry($x - $size->rwidth(), $y - $size->rheight(),
                        $size->rwidth(), $size->rheight());

    # TODO figure out why the 1 and 2 argument form aren't correct in smoke.
    return $y - $size->rheight() -
        this->style()->pixelMetric(Qt4::Style::PM_DefaultLayoutSpacing(), undef, undef);
}
# [20]

# [21]
sub createShapeItem {
    my ($path, $toolTip, $pos, $color) = @_;
    my $shapeItem = ShapeItem();
    $shapeItem->setPath($path);
    $shapeItem->setToolTip($toolTip);
    $shapeItem->setPosition($pos);
    $shapeItem->setColor($color);
    push @{this->shapeItems}, $shapeItem;
    this->update();
}
# [21]

# [22]
sub createToolButton {
    my ($toolTip, $icon, $member) = @_;
    my $button = Qt4::ToolButton(this);
    $button->setToolTip($toolTip);
    $button->setIcon($icon);
    $button->setIconSize(Qt4::Size(32, 32));
    this->connect($button, SIGNAL 'clicked()', this, $member);

    return $button;
}
# [22]

# [23]
sub initialItemPosition {
    my ($path) = @_;
    my $x;
    my $y = (this->height() - int($path->controlPointRect()->height())) / 2;
    if (scalar @{this->shapeItems} == 0) {
        $x = ((3 * this->width()) / 2 - int($path->controlPointRect()->width())) / 2;
    }
    else {
        $x = (this->width() / scalar( @{this->shapeItems} )
             - int($path->controlPointRect()->width())) / 2;
    }

    return Qt4::Point($x, $y);
}
# [23]

# [24]
sub randomItemPosition {
    # 2147483647 is the value of RAND_MAX, defined in stdlib.h, at least on
    # my machine.
    # See the Qt4 documentation on qrand() for more details.
    return Qt4::Point(rand(2147483647) % (this->width() - 120), rand(2147483647) % (this->height() - 120));
}
# [24]

# [25]
sub initialItemColor {
    return Qt4::Color::fromHsv(((scalar @{this->shapeItems} + 1) * 85) % 256, 255, 190);
}
# [25]

# [26]
sub randomItemColor {
    return Qt4::Color::fromHsv(rand(2147483647) % 256, 255, 190);
}
# [26]

1;
