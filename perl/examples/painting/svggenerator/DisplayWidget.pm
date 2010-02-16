package DisplayWidget;

use strict;
use warnings;
use Qt4;
# [DisplayWidget class definition]
use Qt4::isa qw( Qt4::Widget );
use Qt4::slots
    setBackground => ['int'],
    setColor => ['const Qt4::Color &'],
    setShape => ['int'];

use constant { House => 0, Car => 1 };
use constant { Sky => 0, Trees => 1, Road => 2 };
sub background() {
    return this->{background};
}

sub shapeColor() {
    return this->{shapeColor};
}

sub shape() {
    return this->{shape};
}

sub shapeMap() {
    return this->{shapeMap};
}

sub moon() {
    return this->{moon};
}

sub tree() {
    return this->{tree};
}
# [DisplayWidget class definition]

sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
    my $car = Qt4::PainterPath();
    my $house = Qt4::PainterPath();
    this->{tree} = Qt4::PainterPath();
    this->{moon} = Qt4::PainterPath();

    my $file = Qt4::File('resources/shapes.dat');
    $file->open(Qt4::File::ReadOnly());
    my $stream = Qt4::DataStream($file);
    no warnings qw(void);
    $stream >> $car >> $house >> this->{tree} >> this->{moon};
    use warnings;
    $file->close();

    this->{shapeMap} = {
        Car() => $car,
        House() => $house
    };

    this->{background} = Sky;
    this->{shapeColor} = Qt4::Color(Qt4::darkYellow());
    this->{shape} = House;
}

# [paint event]
sub paintEvent
{
    my ($event) = @_;
    my $painter = Qt4::Painter();
    $painter->begin(this);
    $painter->setRenderHint(Qt4::Painter::Antialiasing());
    this->paint($painter);
    $painter->end();
}
# [paint event]

# [paint function]
sub paint
{
    my ($painter) = @_;
#[paint picture]
    $painter->setClipRect(Qt4::Rect(0, 0, 200, 200));
    $painter->setPen(Qt4::NoPen());

    if (this->background == Trees)
    {
        $painter->fillRect(Qt4::Rect(0, 0, 200, 200), Qt4::Color(Qt4::darkGreen()));
        $painter->setBrush(Qt4::Brush(Qt4::Color(Qt4::green())));
        $painter->setPen(Qt4::black());
        for (my $y = -55, my $row = 0; $y < 200; $y += 50, ++$row) {
            my $xs;
            if ($row == 2 || $row == 3) {
                $xs = 150;
            }
            else {
                $xs = 50;
            }
            for (my $x = 0; $x < 200; $x += $xs) {
                $painter->save();
                $painter->translate($x, $y);
                $painter->drawPath(this->tree);
                $painter->restore();
            }
        }
    }
    elsif (this->background == Road) {
        $painter->fillRect(Qt4::Rect(0, 0, 200, 200), Qt4::Color(Qt4::gray()));
        $painter->setPen(Qt4::Pen(Qt4::Brush(Qt4::Color(Qt4::white())), 4, Qt4::DashLine()));
        $painter->drawLine(Qt4::Line(0, 35, 200, 35));
        $painter->drawLine(Qt4::Line(0, 165, 200, 165));
    }
    else {
        $painter->fillRect(Qt4::Rect(0, 0, 200, 200), Qt4::Color(Qt4::darkBlue()));
        $painter->translate(145, 10);
        $painter->setBrush(Qt4::Brush(Qt4::Color(Qt4::white())));
        $painter->drawPath(this->moon);
        $painter->translate(-145, -10);
    }

    $painter->setBrush(Qt4::Brush(this->shapeColor));
    $painter->setPen(Qt4::black());
    $painter->translate(100, 100);
    $painter->drawPath(this->shapeMap->{this->shape});
#[paint picture]
}
# [paint function]

sub color
{
    return this->shapeColor;
}

sub setBackground
{
    my ($background) = @_;
    this->{background} = $background;
    this->update();
}

sub setColor
{
    my ($color) = @_;
    this->{shapeColor} = $color;
    this->update();
}

sub setShape
{
    my ($shape) = @_;
    this->{shape} = $shape;
    this->update();
}

1;
