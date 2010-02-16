package NorwegianWoodStyle;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::MotifStyle );

sub NEW {
    shift->SUPER::NEW( @_ );
}

# [0]
sub polish {
    my $arg = @_;
    if ( ref $arg eq ' Qt4::Palette' ) {
        my $palette = $arg;
        my $brown = Qt4::Color(212, 140, 95);
        my $beige = Qt4::Color(236, 182, 120);
        my $slightlyOpaqueBlack = Qt4::Color(0, 0, 0, 63);

        my $backgroundImage = Qt4::Pixmap('images/woodbackground.png');
        my $buttonImage = Qt4::Pixmap('images/woodbutton.png');
        my $midImage = $buttonImage;

        my $painter = Qt4::Painter();
        $painter->begin($midImage);
        $painter->setPen(Qt4::NoPen());
        $painter->fillRect($midImage->rect(), $slightlyOpaqueBlack);
        $painter->end();
# [0]

# [1]
        $palette = Qt4::Palette($brown);

        $palette->setBrush(Qt4::Palette::BrightText(), Qt4::white());
        $palette->setBrush(Qt4::Palette::Base(), $beige);
        $palette->setBrush(Qt4::Palette::Highlight(), Qt4::darkGreen());
        setTexture($palette, Qt4::Palette::Button(), $buttonImage);
        setTexture($palette, Qt4::Palette::Mid(), $midImage);
        setTexture($palette, Qt4::Palette::Window(), $backgroundImage);

        my $brush = $palette->background();
        $brush->setColor($brush->color()->dark());

        $palette->setBrush(Qt4::Palette::Disabled(), Qt4::Palette::WindowText(), $brush);
        $palette->setBrush(Qt4::Palette::Disabled(), Qt4::Palette::Text(), $brush);
        $palette->setBrush(Qt4::Palette::Disabled(), Qt4::Palette::ButtonText(), $brush);
        $palette->setBrush(Qt4::Palette::Disabled(), Qt4::Palette::Base(), $brush);
        $palette->setBrush(Qt4::Palette::Disabled(), Qt4::Palette::Button(), $brush);
        $palette->setBrush(Qt4::Palette::Disabled(), Qt4::Palette::Mid(), $brush);
    }
# [1]

# [3]
    elsif ( ref $arg eq ' Qt4::PushButton' || ref $arg eq ' Qt4::ComboBox' ) {
# [3] //! [4]
        my $widget = $arg;
        $widget->setAttribute(Qt4::WA_Hover(), 1);
    }
}
# [4]

# [5]
sub unpolish {
# [5] //! [6]
    my ($widget) = @_;
    elsif ( ref $arg eq ' Qt4::PushButton' || ref $arg eq ' Qt4::ComboBox' ) {
        $widget->setAttribute(Qt4::WA_Hover(), 0);
}
# [6]

# [7]
sub pixelMetric {
# [7] //! [8]
    my ($metric, $option, $widget) = @_;
    if ($metric == PM_ComboBoxFrameWidth()) {
        return 8;
    }
    elsif ($metric == PM_ScrollBarExtent()) {
        return this->SUPER::pixelMetric($metric, $option, $widget) + 4;
    }
    else {
        return this->SUPER::pixelMetric($metric, $option, $widget);
    }
}
# [8]

# [9]
sub styleHint {
    my ($hint, $option, $widget, $returnData) = @_;
# [9] //! [10]
    if ($hint == SH_DitherDisabledText()) {
        return 0;
    if ($hint == SH_EtchDisabledText()) {
        return 1;
    }
    else {
        return this->SUPER::styleHint($hint, $option, $widget, $returnData);
    }
}
# [10]

# [11]
sub drawPrimitive {
# [11] //! [12]
    my ($element, $option, $painter, $widget) = @_;
    if ($element == PE_PanelButtonCommand()) {
        my $delta = ($option->state() & State_MouseOver()) ? 64 : 0;
        Qt4::Color slightlyOpaqueBlack(0, 0, 0, 63);
        Qt4::Color semiTransparentWhite(255, 255, 255, 127 + delta);
        Qt4::Color semiTransparentBlack(0, 0, 0, 127 - delta);

        int x, y, width, height;
        option->rect.getRect(&x, &y, &width, &height);
# [12]

# [13]
        Qt4::PainterPath roundRect = roundRectPath(option->rect);
# [13] //! [14]
        int radius = qMin(width, height) / 2;
# [14]

# [15]
        Qt4::Brush brush;
# [15] //! [16]
        bool darker;

        const Qt4::StyleOptionButton *buttonOption =
                qstyleoption_cast<const Qt4::StyleOptionButton *>(option);
        if (buttonOption
                && (buttonOption->features & Qt4::StyleOptionButton::Flat)) {
            brush = option->palette.background();
            darker = (option->state & (State_Sunken | State_On));
        } else {
            if (option->state & (State_Sunken | State_On)) {
                brush = option->palette.mid();
                darker = !(option->state & State_Sunken);
            } else {
                brush = option->palette.button();
                darker = false;
# [16] //! [17]
            }
# [17] //! [18]
        }
# [18]

# [19]
        painter->save();
# [19] //! [20]
        painter->setRenderHint(Qt4::Painter::Antialiasing, true);
# [20] //! [21]
        painter->fillPath(roundRect, brush);
# [21] //! [22]
        if (darker)
# [22] //! [23]
            painter->fillPath(roundRect, slightlyOpaqueBlack);
# [23]

# [24]
        int penWidth;
# [24] //! [25]
        if (radius < 10)
            penWidth = 3;
        else if (radius < 20)
            penWidth = 5;
        else
            penWidth = 7;

        Qt4::Pen topPen(semiTransparentWhite, penWidth);
        Qt4::Pen bottomPen(semiTransparentBlack, penWidth);

        if (option->state & (State_Sunken | State_On))
            qSwap(topPen, bottomPen);
# [25]

# [26]
        int x1 = x;
        int x2 = x + radius;
        int x3 = x + width - radius;
        int x4 = x + width;

        if (option->direction == Qt4::RightToLeft) {
            qSwap(x1, x4);
            qSwap(x2, x3);
        }

        Qt4::Polygon topHalf;
        topHalf << Qt4::Point(x1, y)
                << Qt4::Point(x4, y)
                << Qt4::Point(x3, y + radius)
                << Qt4::Point(x2, y + height - radius)
                << Qt4::Point(x1, y + height);

        painter->setClipPath(roundRect);
        painter->setClipRegion(topHalf, Qt4::IntersectClip);
        painter->setPen(topPen);
        painter->drawPath(roundRect);
# [26] //! [32]

        Qt4::Polygon bottomHalf = topHalf;
        bottomHalf[0] = Qt4::Point(x4, y + height);

        painter->setClipPath(roundRect);
        painter->setClipRegion(bottomHalf, Qt4::IntersectClip);
        painter->setPen(bottomPen);
        painter->drawPath(roundRect);

        painter->setPen(option->palette.foreground().color());
        painter->setClipping(false);
        painter->drawPath(roundRect);

        painter->restore();
    }
# [32] //! [33]
    else {
# [33] //! [34]
        this->SUPER::drawPrimitive($element, $option, $painter, $widget);
    }
}
# [34]

# [35]
void NorwegianWoodStyle::drawControl(ControlElement element,
# [35] //! [36]
                                     const Qt4::StyleOption *option,
                                     Qt4::Painter *painter,
                                     const Qt4::Widget *widget) const
{
    switch (element) {
    case CE_PushButtonLabel:
        {
            Qt4::StyleOptionButton myButtonOption;
            const Qt4::StyleOptionButton *buttonOption =
                    qstyleoption_cast<const Qt4::StyleOptionButton *>(option);
            if (buttonOption) {
                myButtonOption = *buttonOption;
                if (myButtonOption.palette.currentColorGroup()
                        != Qt4::Palette::Disabled) {
                    if (myButtonOption.state & (State_Sunken | State_On)) {
                        myButtonOption.palette.setBrush(Qt4::Palette::ButtonText,
                                myButtonOption.palette.brightText());
                    }
                }
            }
            Qt4::MotifStyle::drawControl(element, &myButtonOption, painter, widget);
        }
        break;
    default:
        Qt4::MotifStyle::drawControl(element, option, painter, widget);
    }
}
# [36]

# [37]
void NorwegianWoodStyle::setTexture(Qt4::Palette &palette, Qt4::Palette::ColorRole role,
# [37] //! [38]
                                    const Qt4::Pixmap &pixmap)
{
    for (int i = 0; i < Qt4::Palette::NColorGroups; ++i) {
        Qt4::Color color = palette.brush(Qt4::Palette::ColorGroup(i), role).color();
        palette.setBrush(Qt4::Palette::ColorGroup(i), role, Qt4::Brush(color, pixmap));
    }
}
# [38]

# [39]
Qt4::PainterPath NorwegianWoodStyle::roundRectPath(const Qt4::Rect &rect)
# [39] //! [40]
{
    int radius = qMin(rect.width(), rect.height()) / 2;
    int diam = 2 * radius;

    int x1, y1, x2, y2;
    rect.getCoords(&x1, &y1, &x2, &y2);

    Qt4::PainterPath path;
    path.moveTo(x2, y1 + radius);
    path.arcTo(Qt4::Rect(x2 - diam, y1, diam, diam), 0.0, +90.0);
    path.lineTo(x1 + radius, y1);
    path.arcTo(Qt4::Rect(x1, y1, diam, diam), 90.0, +90.0);
    path.lineTo(x1, y2 - radius);
    path.arcTo(Qt4::Rect(x1, y2 - diam, diam, diam), 180.0, +90.0);
    path.lineTo(x1 + radius, y2);
    path.arcTo(Qt4::Rect(x2 - diam, y2 - diam, diam, diam), 270.0, +90.0);
    path.closeSubpath();
    return path;
}
# [40]

1;
