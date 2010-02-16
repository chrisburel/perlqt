package DragLabel;

use strict;
use warnings;
use Qt4;
# [0]
use Qt4::isa qw( Qt4::Label );
sub m_labelText() {
    return this->{m_labelText};
}

# [0]
sub NEW
{
    my ($class, $text, $parent) = @_;
    $class->SUPER::NEW($parent);

    my $metric = Qt4::FontMetrics(this->font());
    my $size = $metric->size(Qt4::TextSingleLine(), $text);

    my $image = Qt4::Image($size->width() + 12, $size->height() + 12,
                 Qt4::Image::Format_ARGB32_Premultiplied());
    $image->fill(0x00000000);

    my $font = Qt4::Font();
    $font->setStyleStrategy(Qt4::Font::ForceOutline());
# [0]

# [1]
    my $gradient = Qt4::LinearGradient(0, 0, 0, $image->height()-1);
    $gradient->setColorAt(0.0, Qt4::Color(Qt4::white()));
    $gradient->setColorAt(0.2, Qt4::Color(200, 200, 255));
    $gradient->setColorAt(0.8, Qt4::Color(200, 200, 255));
    $gradient->setColorAt(1.0, Qt4::Color(127, 127, 200));

    my $painter = Qt4::Painter();
    $painter->begin($image);
    $painter->setRenderHint(Qt4::Painter::Antialiasing());
    $painter->setBrush(Qt4::Brush($gradient));
    $painter->drawRoundedRect(Qt4::RectF(0.5, 0.5, $image->width()-1, $image->height()-1),
                            25, 25, Qt4::RelativeSize());

    $painter->setFont($font);
    $painter->setBrush(Qt4::Brush(Qt4::black()));
    $painter->drawText(Qt4::Rect(Qt4::Point(6, 6), $size), Qt4::AlignCenter(), $text);
    $painter->end();
# [1]

# [2]
    this->setPixmap(Qt4::Pixmap::fromImage($image));
    this->{m_labelText} = $text;
}
# [2]

sub labelText
{
    return this->{m_labelText};
}

1;
