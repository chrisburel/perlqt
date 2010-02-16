package Window;

use strict;
use warnings;
use Qt;
use Ui_Window;
use DisplayWidget;
# [Window class definition]
use Qt::isa qw( Qt::Widget );
use Qt::slots
    saveSvg => [],
    updateBackground => ['int'],
    updateColor => [],
    updateShape => ['int'];

sub path() {
    return this->{path};
}
# [Window class definition]


sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
    Ui_Window->setupUi(this);
}

sub updateBackground
{
    my ($background) = @_;
    this->displayWidget->setBackground(DisplayWidget::Background($background));
}

sub updateColor
{
    my $color = Qt::ColorDialog::getColor(this->displayWidget->color());
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
    my $newPath = Qt::FileDialog::getSaveFileName(this, this->tr('Save SVG'),
        this->path, this->tr('SVG files (*.svg)'));

    if (!$newPath) {
        return;
    }

    this->{path} = $newPath;

#[configure SVG generator]
    my $generator = Qt::SvgGenerator();
    $generator->setFileName(this->path);
    $generator->setSize(Qt::Size(200, 200));
    $generator->setViewBox(Qt::Rect(0, 0, 200, 200));
    $generator->setTitle(this->tr('SVG Generator Example Drawing'));
    $generator->setDescription(this->tr('An SVG drawing created by the SVG Generator ' .
                                'Example provided with Qt.'));
#[configure SVG generator]
#[begin painting]
    my $painter = Qt::Painter();
    $painter->begin($generator);
#[begin painting]
    this->displayWidget->paint($painter);
#[end painting]
    $painter->end();
#[end painting]
}
# [save SVG]

1;
