package Window;

use strict;
use warnings;
use Qt4;
# [0]
use Qt4::isa qw( Qt4::Widget );
use Qt4::slots
    shapeChanged => [],
    penChanged => [],
    brushChanged => [];

use RenderArea;

sub renderArea() {
    return this->{renderArea};
}

sub shapeLabel() {
    return this->{shapeLabel};
}

sub penWidthLabel() {
    return this->{penWidthLabel};
}

sub penStyleLabel() {
    return this->{penStyleLabel};
}

sub penCapLabel() {
    return this->{penCapLabel};
}

sub penJoinLabel() {
    return this->{penJoinLabel};
}

sub brushStyleLabel() {
    return this->{brushStyleLabel};
}

sub otherOptionsLabel() {
    return this->{otherOptionsLabel};
}

sub shapeComboBox() {
    return this->{shapeComboBox};
}

sub penWidthSpinBox() {
    return this->{penWidthSpinBox};
}

sub penStyleComboBox() {
    return this->{penStyleComboBox};
}

sub penCapComboBox() {
    return this->{penCapComboBox};
}

sub penJoinComboBox() {
    return this->{penJoinComboBox};
}

sub brushStyleComboBox() {
    return this->{brushStyleComboBox};
}

sub antialiasingCheckBox() {
    return this->{antialiasingCheckBox};
}

sub transformationsCheckBox() {
    return this->{transformationsCheckBox};
}

# [0]
use constant IdRole => Qt4::UserRole();
# [0]

# [1]
sub NEW
{
    my ($class) = @_;
    $class->SUPER::NEW();
    this->{renderArea} = RenderArea();

    this->{shapeComboBox} = Qt4::ComboBox();
    this->shapeComboBox->addItem(this->tr('Polygon'), Qt4::Variant(Qt4::Int(RenderArea::Polygon())));
    this->shapeComboBox->addItem(this->tr('Rectangle'), Qt4::Variant(Qt4::Int(RenderArea::Rect())));
    this->shapeComboBox->addItem(this->tr('Rounded Rectangle'), Qt4::Variant(Qt4::Int(RenderArea::RoundedRect())));
    this->shapeComboBox->addItem(this->tr('Ellipse'), Qt4::Variant(Qt4::Int(RenderArea::Ellipse())));
    this->shapeComboBox->addItem(this->tr('Pie'), Qt4::Variant(Qt4::Int(RenderArea::Pie())));
    this->shapeComboBox->addItem(this->tr('Chord'), Qt4::Variant(Qt4::Int(RenderArea::Chord())));
    this->shapeComboBox->addItem(this->tr('Path'), Qt4::Variant(Qt4::Int(RenderArea::Path())));
    this->shapeComboBox->addItem(this->tr('Line'), Qt4::Variant(Qt4::Int(RenderArea::Line())));
    this->shapeComboBox->addItem(this->tr('Polyline'), Qt4::Variant(Qt4::Int(RenderArea::Polyline())));
    this->shapeComboBox->addItem(this->tr('Arc'), Qt4::Variant(Qt4::Int(RenderArea::Arc())));
    this->shapeComboBox->addItem(this->tr('Points'), Qt4::Variant(Qt4::Int(RenderArea::Points())));
    this->shapeComboBox->addItem(this->tr('Text'), Qt4::Variant(Qt4::Int(RenderArea::Text())));
    this->shapeComboBox->addItem(this->tr('Pixmap'), Qt4::Variant(Qt4::Int(RenderArea::Pixmap())));

    this->{shapeLabel} = Qt4::Label(this->tr('&Shape:'));
    this->shapeLabel->setBuddy(this->shapeComboBox);
# [1]

# [2]
    this->{penWidthSpinBox} = Qt4::SpinBox();
    this->penWidthSpinBox->setRange(0, 20);
    this->penWidthSpinBox->setSpecialValueText(this->tr('0 (cosmetic pen)'));

    this->{penWidthLabel} = Qt4::Label(this->tr('Pen &Width:'));
    this->penWidthLabel->setBuddy(this->penWidthSpinBox);
# [2]

# [3]
    this->{penStyleComboBox} = Qt4::ComboBox();
    this->penStyleComboBox->addItem(this->tr('Solid'), Qt4::Variant(Qt4::Int(${Qt4::SolidLine()})));
    this->penStyleComboBox->addItem(this->tr('Dash'), Qt4::Variant(Qt4::Int(${Qt4::DashLine()})));
    this->penStyleComboBox->addItem(this->tr('Dot'), Qt4::Variant(Qt4::Int(${Qt4::DotLine()})));
    this->penStyleComboBox->addItem(this->tr('Dash Dot'), Qt4::Variant(Qt4::Int(${Qt4::DashDotLine()})));
    this->penStyleComboBox->addItem(this->tr('Dash Dot Dot'), Qt4::Variant(Qt4::Int(${Qt4::DashDotDotLine()})));
    this->penStyleComboBox->addItem(this->tr('None'), Qt4::Variant(Qt4::Int(${Qt4::NoPen()})));

    this->{penStyleLabel} = Qt4::Label(this->tr('&Pen Style:'));
    this->penStyleLabel->setBuddy(this->penStyleComboBox);

    this->{penCapComboBox} = Qt4::ComboBox();
    this->penCapComboBox->addItem(this->tr('Flat'), Qt4::Variant(Qt4::Int(${Qt4::FlatCap()})));
    this->penCapComboBox->addItem(this->tr('Square'), Qt4::Variant(Qt4::Int(${Qt4::SquareCap()})));
    this->penCapComboBox->addItem(this->tr('Round'), Qt4::Variant(Qt4::Int(${Qt4::RoundCap()})));

    this->{penCapLabel} = Qt4::Label(this->tr('Pen &Cap:'));
    this->penCapLabel->setBuddy(this->penCapComboBox);

    this->{penJoinComboBox} = Qt4::ComboBox();
    this->penJoinComboBox->addItem(this->tr('Miter'), Qt4::Variant(Qt4::Int(${Qt4::MiterJoin()})));
    this->penJoinComboBox->addItem(this->tr('Bevel'), Qt4::Variant(Qt4::Int(${Qt4::BevelJoin()})));
    this->penJoinComboBox->addItem(this->tr('Round'), Qt4::Variant(Qt4::Int(${Qt4::RoundJoin()})));

    this->{penJoinLabel} = Qt4::Label(this->tr('Pen &Join:'));
    this->penJoinLabel->setBuddy(this->penJoinComboBox);
# [3]

# [4]
    this->{brushStyleComboBox} = Qt4::ComboBox();
    this->brushStyleComboBox->addItem(this->tr('Linear Gradient'),
            Qt4::Variant(Qt4::Int(${Qt4::LinearGradientPattern()})));
    this->brushStyleComboBox->addItem(this->tr('Radial Gradient'),
            Qt4::Variant(Qt4::Int(${Qt4::RadialGradientPattern()})));
    this->brushStyleComboBox->addItem(this->tr('Conical Gradient'),
            Qt4::Variant(Qt4::Int(${Qt4::ConicalGradientPattern()})));
    this->brushStyleComboBox->addItem(this->tr('Texture'), Qt4::Variant(Qt4::Int(${Qt4::TexturePattern()})));
    this->brushStyleComboBox->addItem(this->tr('Solid'), Qt4::Variant(Qt4::Int(${Qt4::SolidPattern()})));
    this->brushStyleComboBox->addItem(this->tr('Horizontal'), Qt4::Variant(Qt4::Int(${Qt4::HorPattern()})));
    this->brushStyleComboBox->addItem(this->tr('Vertical'), Qt4::Variant(Qt4::Int(${Qt4::VerPattern()})));
    this->brushStyleComboBox->addItem(this->tr('Cross'), Qt4::Variant(Qt4::Int(${Qt4::CrossPattern()})));
    this->brushStyleComboBox->addItem(this->tr('Backward Diagonal'), Qt4::Variant(Qt4::Int(${Qt4::BDiagPattern()})));
    this->brushStyleComboBox->addItem(this->tr('Forward Diagonal'), Qt4::Variant(Qt4::Int(${Qt4::FDiagPattern()})));
    this->brushStyleComboBox->addItem(this->tr('Diagonal Cross'), Qt4::Variant(Qt4::Int(${Qt4::DiagCrossPattern()})));
    this->brushStyleComboBox->addItem(this->tr('Dense 1'), Qt4::Variant(Qt4::Int(${Qt4::Dense1Pattern()})));
    this->brushStyleComboBox->addItem(this->tr('Dense 2'), Qt4::Variant(Qt4::Int(${Qt4::Dense2Pattern()})));
    this->brushStyleComboBox->addItem(this->tr('Dense 3'), Qt4::Variant(Qt4::Int(${Qt4::Dense3Pattern()})));
    this->brushStyleComboBox->addItem(this->tr('Dense 4'), Qt4::Variant(Qt4::Int(${Qt4::Dense4Pattern()})));
    this->brushStyleComboBox->addItem(this->tr('Dense 5'), Qt4::Variant(Qt4::Int(${Qt4::Dense5Pattern()})));
    this->brushStyleComboBox->addItem(this->tr('Dense 6'), Qt4::Variant(Qt4::Int(${Qt4::Dense6Pattern()})));
    this->brushStyleComboBox->addItem(this->tr('Dense 7'), Qt4::Variant(Qt4::Int(${Qt4::Dense7Pattern()})));
    this->brushStyleComboBox->addItem(this->tr('None'), Qt4::Variant(Qt4::Int(${Qt4::NoBrush()})));

    this->{brushStyleLabel} = Qt4::Label(this->tr('&Brush Style:'));
    this->brushStyleLabel->setBuddy(this->brushStyleComboBox);
# [4]

# [5]
    this->{otherOptionsLabel} = Qt4::Label(this->tr('Other Options:'));
# [5] //! [6]
    this->{antialiasingCheckBox} = Qt4::CheckBox(this->tr('&Antialiasing'));
# [6] //! [7]
    this->{transformationsCheckBox} = Qt4::CheckBox(this->tr('&Transformations'));
# [7]

# [8]
    this->connect(this->shapeComboBox, SIGNAL 'activated(int)',
            this, SLOT 'shapeChanged()');
    this->connect(this->penWidthSpinBox, SIGNAL 'valueChanged(int)',
            this, SLOT 'penChanged()');
    this->connect(this->penStyleComboBox, SIGNAL 'activated(int)',
            this, SLOT 'penChanged()');
    this->connect(this->penCapComboBox, SIGNAL 'activated(int)',
            this, SLOT 'penChanged()');
    this->connect(this->penJoinComboBox, SIGNAL 'activated(int)',
            this, SLOT 'penChanged()');
    this->connect(this->brushStyleComboBox, SIGNAL 'activated(int)',
            this, SLOT 'brushChanged()');
    this->connect(this->antialiasingCheckBox, SIGNAL 'toggled(bool)',
            this->renderArea, SLOT 'setAntialiased(bool)');
    this->connect(this->transformationsCheckBox, SIGNAL 'toggled(bool)',
            this->renderArea, SLOT 'setTransformed(bool)');
# [8]

# [9]
    my $mainLayout = Qt4::GridLayout();
# [9] //! [10]
    $mainLayout->setColumnStretch(0, 1);
    $mainLayout->setColumnStretch(3, 1);
    $mainLayout->addWidget(renderArea, 0, 0, 1, 4);
    $mainLayout->setRowMinimumHeight(1, 6);
    $mainLayout->addWidget(this->shapeLabel, 2, 1, Qt4::AlignRight());
    $mainLayout->addWidget(this->shapeComboBox, 2, 2);
    $mainLayout->addWidget(this->penWidthLabel, 3, 1, Qt4::AlignRight());
    $mainLayout->addWidget(this->penWidthSpinBox, 3, 2);
    $mainLayout->addWidget(this->penStyleLabel, 4, 1, Qt4::AlignRight());
    $mainLayout->addWidget(this->penStyleComboBox, 4, 2);
    $mainLayout->addWidget(this->penCapLabel, 5, 1, Qt4::AlignRight());
    $mainLayout->addWidget(this->penCapComboBox, 5, 2);
    $mainLayout->addWidget(this->penJoinLabel, 6, 1, Qt4::AlignRight());
    $mainLayout->addWidget(this->penJoinComboBox, 6, 2);
    $mainLayout->addWidget(this->brushStyleLabel, 7, 1, Qt4::AlignRight());
    $mainLayout->addWidget(this->brushStyleComboBox, 7, 2);
    $mainLayout->setRowMinimumHeight(8, 6);
    $mainLayout->addWidget(this->otherOptionsLabel, 9, 1, Qt4::AlignRight());
    $mainLayout->addWidget(this->antialiasingCheckBox, 9, 2);
    $mainLayout->addWidget(this->transformationsCheckBox, 10, 2);
    this->setLayout($mainLayout);

    this->shapeChanged();
    this->penChanged();
    this->brushChanged();
    this->antialiasingCheckBox->setChecked(1);

    setWindowTitle(this->tr('Basic Drawing'));
}
# [10]

# [11]
sub shapeChanged
{
    my $shape = this->shapeComboBox->itemData(
            this->shapeComboBox->currentIndex(), IdRole)->toInt();
    this->renderArea->setShape($shape);
}
# [11]

# [12]
sub penChanged
{
    my $width = this->penWidthSpinBox->value();
    my $style = this->penStyleComboBox->itemData(
            this->penStyleComboBox->currentIndex(), IdRole)->toInt();
    my $cap = this->penCapComboBox->itemData(
            this->penCapComboBox->currentIndex(), IdRole)->toInt();
    my $join = this->penJoinComboBox->itemData(
            this->penJoinComboBox->currentIndex(), IdRole)->toInt();

    this->renderArea->setPen(Qt4::Pen(Qt4::Brush(Qt4::Color(Qt4::blue())), $width, $style, $cap, $join));
}
# [12]

# [13]
sub brushChanged
{
    my $style = this->brushStyleComboBox->itemData(
# [13]
            this->brushStyleComboBox->currentIndex(), IdRole)->toInt();

# [14]
    if ($style == Qt4::LinearGradientPattern()) {
        my $linearGradient = Qt4::LinearGradient(0, 0, 100, 100);
        $linearGradient->setColorAt(0.0, Qt4::Color(Qt4::white()));
        $linearGradient->setColorAt(0.2, Qt4::Color(Qt4::green()));
        $linearGradient->setColorAt(1.0, Qt4::Color(Qt4::black()));
        this->renderArea->setBrush($linearGradient);
# [14] //! [15]
    } elsif ($style == Qt4::RadialGradientPattern()) {
        my $radialGradient = Qt4::RadialGradient(50, 50, 50, 70, 70);
        $radialGradient->setColorAt(0.0, Qt4::Color(Qt4::white()));
        $radialGradient->setColorAt(0.2, Qt4::Color(Qt4::green()));
        $radialGradient->setColorAt(1.0, Qt4::Color(Qt4::black()));
        this->renderArea->setBrush($radialGradient);
    } elsif ($style == Qt4::ConicalGradientPattern()) {
        my $conicalGradient = Qt4::ConicalGradient(50, 50, 150);
        $conicalGradient->setColorAt(0.0, Qt4::Color(Qt4::white()));
        $conicalGradient->setColorAt(0.2, Qt4::Color(Qt4::green()));
        $conicalGradient->setColorAt(1.0, Qt4::Color(Qt4::black()));
        this->renderArea->setBrush($conicalGradient);
# [15] //! [16]
    } elsif ($style == Qt4::TexturePattern()) {
        this->renderArea->setBrush(Qt4::Brush(Qt4::Pixmap('images/brick.png')));
# [16] //! [17]
    } else {
        this->renderArea->setBrush(Qt4::Brush(Qt4::green(), $style));
    }
}
# [17]

1;
