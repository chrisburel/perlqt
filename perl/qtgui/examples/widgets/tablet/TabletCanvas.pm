package TabletCanvas;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Widget );

use Exporter;
use base qw( Exporter );
our @EXPORT_OK = qw( AlphaPressure AlphaTilt NoAlpha SaturationVTilt 
    SaturationHTilt SaturationPressure NoSaturation LineWidthPressure
    LineWidthTilt NoLineWidth );

use constant {
    AlphaPressure => 1,
    AlphaTilt => 2,
    NoAlpha => 3,
};

use constant {
    SaturationVTilt => 1,
    SaturationHTilt => 2,
    SaturationPressure => 3,
    NoSaturation => 4,
};

use constant {
    LineWidthPressure => 1,
    LineWidthTilt => 2,
    NoLineWidth => 3,
};

sub setAlphaChannelType {
    this->{alphaChannelType} = shift;
}

sub setColorSaturationType {
    this->{colorSaturationType} = shift;
}

sub setLineWidthType {
    this->{lineWidthType} = shift;
}

sub setColor {
    this->{myColor} = Qt4::Color(shift);
}

sub color {
    return this->myColor;
}

sub setTabletDevice {
    this->{myTabletDevice} = shift;
}

sub maximum {
    my ( $a, $b ) = @_;
    return $a > $b ? $a : $b;
}

sub alphaChannelType() {
    return this->{alphaChannelType};
}

sub colorSaturationType() {
    return this->{colorSaturationType};
}

sub lineWidthType() {
    return this->{lineWidthType};
}

sub pointerType() {
    return this->{pointerType};
}

sub myTabletDevice() {
    return this->{myTabletDevice};
}

sub myColor() {
    return this->{myColor};
}

sub image() {
    return this->{image};
}

sub myBrush() {
    return this->{myBrush};
}

sub myPen() {
    return this->{myPen};
}

sub deviceDown() {
    return this->{deviceDown};
}

sub polyLine() {
    return this->{polyLine};
}

# [0]
sub NEW {
    my ( $class ) = @_;
    $class->SUPER::NEW();
    this->resize(500, 500);
    this->{myBrush} = Qt4::Brush();
    this->{myPen} = Qt4::Pen();
    this->initImage();
    this->setAutoFillBackground(1);
    this->{deviceDown} = 0;
    this->setColor( Qt4::red() );
    this->{myTabletDevice} = Qt4::TabletEvent::Stylus();
    this->{alphaChannelType} = NoAlpha;
    this->{colorSaturationType} = NoSaturation;
    this->{lineWidthType} = LineWidthPressure;
}

sub initImage {
    my $newImage = Qt4::Image(this->width(), this->height(), Qt4::Image::Format_ARGB32());
    my $painter = Qt4::Painter($newImage);
    $painter->fillRect(0, 0, $newImage->width(), $newImage->height(), Qt4::Brush(Qt4::white()));
    if (this->image && !this->image->isNull()) {
        $painter->drawImage(0, 0, this->image);
    }
    $painter->end();
    this->{image} = $newImage;
}
# [0]

# [1]
sub saveImage {
    my ($file) = @_;
    return this->image->save($file);
}
# [1]

# [2]
sub loadImage {
    my ($file) = @_;
    my $success = this->image->load($file);

    if ($success) {
        this->update();
        return 1;
    }
    return 0;
}
# [2]

# [3]
sub tabletEvent {
    my ($event) = @_;

    if ( $event->type() == Qt4::Event::TabletPress() ) {
        if (!this->deviceDown) {
            this->{deviceDown} = 1;
        }
    }
    elsif ( $event->type() == Qt4::Event::TabletRelease() ) {
        if (this->deviceDown) {
            this->{deviceDown} = 0;
        }
    }
    elsif ( $event->type() == Qt4::Event::TabletMove() ) {
        unshift @{this->polyLine}, $event->pos();
        delete this->polyLine->[3];

        if (this->deviceDown) {
            this->updateBrush($event);
            my $painter = Qt4::Painter(this->image);
            this->paintImage($painter, $event);
            $painter->end();
        }
    }
    this->update();
}
# [3]

# [4]
sub paintEvent {
    my $painter = Qt4::Painter(this);
    $painter->drawImage(Qt4::Point(0, 0), this->image);
    $painter->end();
}
# [4]

# [5]
sub paintImage {
    my ($painter, $event) = @_;
    my $brushAdjust = Qt4::Point(10, 10);

    my $myTabletDevice = this->myTabletDevice;
    if ( $myTabletDevice == Qt4::TabletEvent::Stylus() ) {
        $painter->setBrush(this->myBrush);
        $painter->setPen(this->myPen);
        $painter->drawLine(this->polyLine->[1], $event->pos());
    }
    elsif ( $myTabletDevice == Qt4::TabletEvent::Airbrush() ) {
        this->myBrush->setColor(this->myColor);
        this->myBrush->setStyle(this->brushPattern($event->pressure()));
        $painter->setPen(Qt4::NoPen());
        $painter->setBrush(this->myBrush);

        foreach my $i (0..2) {
            $painter->drawEllipse(Qt4::Rect(this->polyLine->[$i] - $brushAdjust,
                                this->polyLine->[$i] + $brushAdjust));
        }
    }
    elsif ( $myTabletDevice == Qt4::TabletEvent::Puck() ||
         $myTabletDevice == Qt4::TabletEvent::FourDMouse() ||
         $myTabletDevice == Qt4::TabletEvent::RotationStylus() ) {
        warn("This input device is not supported by the example.");
    }
    else {
        warn("Unknown tablet device.");
    }
}
# [5]

# [6]
sub brushPattern {
    my ($value) = @_;
    my $pattern = int(($value) * 100.0) % 7;

    if ( $pattern == 0 ) {
        return Qt4::SolidPattern();
    }
    elsif ( $pattern == 1 ) {
        return Qt4::Dense1Pattern();
    }
    elsif ( $pattern == 2 ) {
        return Qt4::Dense2Pattern();
    }
    elsif ( $pattern == 3 ) {
        return Qt4::Dense3Pattern();
    }
    elsif ( $pattern == 4 ) {
        return Qt4::Dense4Pattern();
    }
    elsif ( $pattern == 5 ) {
        return Qt4::Dense5Pattern();
    }
    elsif ( $pattern == 6 ) {
        return Qt4::Dense6Pattern();
    }
    else {
        return Qt4::Dense7Pattern();
    }
}
# [6]

# [7]
sub updateBrush {
    my ($event) = @_;
    my ( $hue, $saturation, $value, $alpha );
    this->myColor->getHsv($hue, $saturation, $value, $alpha);

    my $vValue = int((($event->yTilt() + 60.0) / 120.0) * 255);
    my $hValue = int((($event->xTilt() + 60.0) / 120.0) * 255);
# [7] //! [8]

    my $alphaChannelType = this->alphaChannelType;
    if ( $alphaChannelType == AlphaPressure ) {
        this->myColor->setAlpha(int($event->pressure() * 255.0));
    }
    elsif ( $alphaChannelType == AlphaTilt ) {
        this->myColor->setAlpha(maximum(abs($vValue - 127), abs($hValue - 127)));
    }
    else {
        this->myColor->setAlpha(255);
    }

# [8] //! [9]
    my $colorSaturationType = this->colorSaturationType;
    if ( $colorSaturationType == SaturationVTilt ) {
        this->myColor->setHsv($hue, $vValue, $value, $alpha);
    }
    elsif ( $colorSaturationType == SaturationHTilt ) {
        this->myColor->setHsv($hue, $hValue, $value, $alpha);
    }
    elsif ( $colorSaturationType == SaturationPressure ) {
        this->myColor->setHsv($hue, int($event->pressure() * 255.0), $value, $alpha);
    }

# [9] //! [10]
    my $lineWidthType = this->lineWidthType;
    if ( $lineWidthType == LineWidthPressure ) {
        this->myPen->setWidthF($event->pressure() * 10 + 1);
    }
    elsif ( $lineWidthType == LineWidthTilt ) {
        this->myPen->setWidthF(maximum(abs($vValue - 127), abs($hValue - 127)) / 12);
    }
    else {
        this->myPen->setWidthF(1);
    }

# [10] //! [11]
    if ($event->pointerType() == Qt4::TabletEvent::Eraser()) {
        this->myBrush->setColor(Qt4::white());
        this->myPen->setColor(Qt4::white());
        this->myPen->setWidthF($event->pressure() * 10 + 1);
    } else {
        this->myBrush->setColor(this->myColor);
        this->myPen->setColor(this->myColor);
    }
}
# [11]

sub resizeEvent {
    my ($event) = @_;
    this->initImage();
    this->{polyLine} = [];
    this->polyLine->[0] = this->polyLine->[1] = this->polyLine->[2] = Qt4::Point();
}

1;
