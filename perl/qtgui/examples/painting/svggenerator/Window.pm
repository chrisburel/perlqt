package Window;

use strict;
use warnings;
use Qt4;
use Ui_Window;
use DisplayWidget;
# [Window class definition]
use Qt4::isa qw( Qt4::Widget );
use Qt4::slots
    saveSvg => [],
    updateBackground => ['int'],
    updateColor => [],
    updateShape => ['int'];

sub path() {
    return this->{path};
}

sub ui() {
    return this->{ui};
}

sub displayWidget {
    return this->ui->{displayWidget};
}

# [Window class definition]


sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
    this->{ui} = Ui_Window->setupUi(this);
}

sub updateBackground
{
    my ($background) = @_;
    this->displayWidget->setBackground($background);
}

sub updateColor
{
    my $color = Qt4::ColorDialog::getColor(this->displayWidget->color());
    if ($color->isValid()) {
        this->displayWidget->setColor($color);
    }
}

sub updateShape
{
    my ($shape) = @_;
    this->displayWidget->setShape($shape);
}

# [save SVG]
sub saveSvg
{
    my $newPath = Qt4::FileDialog::getSaveFileName(this, this->tr('Save SVG'),
        this->path, this->tr('SVG files (*.svg)'));

    if (!$newPath) {
        return;
    }

    this->{path} = $newPath;

#[configure SVG generator]
    my $generator = Qt4::SvgGenerator();
    $generator->setFileName(this->path);
    $generator->setSize(Qt4::Size(200, 200));
    $generator->setViewBox(Qt4::Rect(0, 0, 200, 200));
    $generator->setTitle(this->tr('SVG Generator Example Drawing'));
    $generator->setDescription(this->tr('An SVG drawing created by the SVG Generator ' .
                                'Example provided with Qt4.'));
#[configure SVG generator]
#[begin painting]
    my $painter = Qt4::Painter();
    $painter->begin($generator);
#[begin painting]
    this->displayWidget->paint($painter);
#[end painting]
    $painter->end();
#[end painting]
}
# [save SVG]

1;
