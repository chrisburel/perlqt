package LayoutItem;

use strict;
use warnings;
use Qt4;
# [0]
use Qt4::isa qw( Qt4::GraphicsWidget );

sub pix() {
    return this->{pix};
}

# [0]
sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW( $parent );
    this->{pix} = Qt4::Pixmap('images/block.png');
    # Do not allow a size smaller than the pixmap with two frames around it.
    this->setMinimumSize(Qt4::SizeF(this->pix->size() + Qt4::Size(12, 12)));
}
# [0]

# [1]
sub paint
{
    my ($painter) = @_;

    my $frame = Qt4::RectF(Qt4::PointF(0,0), this->geometry()->size());
    my $w = this->pix->width();
    my $h = this->pix->height();
    my @stops;
# [1]

# [2]
    # paint a background rect (with gradient)
    my $gradient = Qt4::LinearGradient($frame->topLeft(), $frame->topLeft() + Qt4::PointF(200,200));
    push @stops, [0.0, Qt4::Color(60, 60,  60)];
    push @stops, [$frame->height()/2/$frame->height(), Qt4::Color(102, 176, 54)];

    push @stops, [1.0, Qt4::Color(215, 215, 215)];
    $gradient->setStops(\@stops);
    $painter->setBrush(Qt4::Brush($gradient));
    $painter->drawRoundedRect($frame, 10.0, 10.0);

    # paint a rect around the pixmap (with gradient)
    my $pixpos = $frame->center() - (Qt4::PointF($w, $h)/2);
    my $innerFrame = Qt4::RectF($pixpos, Qt4::SizeF($w, $h));
    $innerFrame->adjust(-4, -4, +4, +4);
    $gradient->setStart($innerFrame->topLeft());
    $gradient->setFinalStop($innerFrame->bottomRight());
    @stops = ();
    push @stops, [0.0, Qt4::Color(215, 255, 200)];
    push @stops, [0.5, Qt4::Color(102, 176, 54)];
    push @stops, [1.0, Qt4::Color(0, 0,  0)];
    $gradient->setStops(\@stops);
    $painter->setBrush(Qt4::Brush($gradient));
    $painter->drawRoundedRect($innerFrame, 10.0, 10.0);
    $painter->drawPixmap($pixpos, this->pix);
}
# [2]

1;
