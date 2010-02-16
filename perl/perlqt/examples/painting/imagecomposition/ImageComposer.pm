package ImageComposer;

use strict;
use warnings;
use Qt4;
# [0]
use Qt4::isa qw( Qt4::Widget );
use Qt4::slots
    chooseSource => [],
    chooseDestination => [],
    recalculateResult => [];
# [0]

# [1]
sub sourceButton() {
    return this->{sourceButton};
}

sub destinationButton() {
    return this->{destinationButton};
}

sub operatorComboBox() {
    return this->{operatorComboBox};
}

sub equalLabel() {
    return this->{equalLabel};
}

sub resultLabel() {
    return this->{resultLabel};
}

sub sourceImage() {
    return this->{sourceImage};
}

sub destinationImage() {
    return this->{destinationImage};
}

sub resultImage() {
    return this->{resultImage};
}
# [1]

# [0]
my $resultSize = Qt4::Size(200, 200);
# [0]

# [1]
sub NEW
{
    my ($class) = @_;
    $class->SUPER::NEW();
    this->{sourceImage} = Qt4::Image();
    this->{destinationImage} = Qt4::Image();
    this->{sourceButton} = Qt4::ToolButton();
    this->sourceButton->setIconSize($resultSize);

    this->{operatorComboBox} = Qt4::ComboBox();
    this->addOp(Qt4::Painter::CompositionMode_SourceOver(), this->tr('SourceOver'));
    this->addOp(Qt4::Painter::CompositionMode_DestinationOver(), this->tr('DestinationOver'));
    this->addOp(Qt4::Painter::CompositionMode_Clear(), this->tr('Clear'));
    this->addOp(Qt4::Painter::CompositionMode_Source(), this->tr('Source'));
    this->addOp(Qt4::Painter::CompositionMode_Destination(), this->tr('Destination'));
    this->addOp(Qt4::Painter::CompositionMode_SourceIn(), this->tr('SourceIn'));
    this->addOp(Qt4::Painter::CompositionMode_DestinationIn(), this->tr('DestinationIn'));
    this->addOp(Qt4::Painter::CompositionMode_SourceOut(), this->tr('SourceOut'));
    this->addOp(Qt4::Painter::CompositionMode_DestinationOut(), this->tr('DestinationOut'));
    this->addOp(Qt4::Painter::CompositionMode_SourceAtop(), this->tr('SourceAtop'));
    this->addOp(Qt4::Painter::CompositionMode_DestinationAtop(), this->tr('DestinationAtop'));
    this->addOp(Qt4::Painter::CompositionMode_Xor(), this->tr('Xor'));
    this->addOp(Qt4::Painter::CompositionMode_Plus(), this->tr('Plus'));
    this->addOp(Qt4::Painter::CompositionMode_Multiply(), this->tr('Multiply'));
    this->addOp(Qt4::Painter::CompositionMode_Screen(), this->tr('Screen'));
    this->addOp(Qt4::Painter::CompositionMode_Overlay(), this->tr('Overlay'));
    this->addOp(Qt4::Painter::CompositionMode_Darken(), this->tr('Darken'));
    this->addOp(Qt4::Painter::CompositionMode_Lighten(), this->tr('Lighten'));
    this->addOp(Qt4::Painter::CompositionMode_ColorDodge(), this->tr('ColorDodge'));
    this->addOp(Qt4::Painter::CompositionMode_ColorBurn(), this->tr('ColorBurn'));
    this->addOp(Qt4::Painter::CompositionMode_HardLight(), this->tr('HardLight'));
    this->addOp(Qt4::Painter::CompositionMode_SoftLight(), this->tr('SoftLight'));
    this->addOp(Qt4::Painter::CompositionMode_Difference(), this->tr('Difference'));
    this->addOp(Qt4::Painter::CompositionMode_Exclusion(), this->tr('Exclusion'));
# [1]

# [2]
    this->{destinationButton} = Qt4::ToolButton();
    this->destinationButton->setIconSize($resultSize);

    this->{equalLabel} = Qt4::Label(this->tr('='));

    this->{resultLabel} = Qt4::Label();
    this->resultLabel->setMinimumWidth($resultSize->width());
# [2]

# [3]
    this->connect(this->sourceButton, SIGNAL 'clicked()', this, SLOT 'chooseSource()');
    this->connect(this->operatorComboBox, SIGNAL 'activated(int)',
            this, SLOT 'recalculateResult()');
    this->connect(this->destinationButton, SIGNAL 'clicked()',
            this, SLOT 'chooseDestination()');
# [3]

# [4]
    my $mainLayout = Qt4::GridLayout();
    $mainLayout->addWidget(this->sourceButton, 0, 0, 3, 1);
    $mainLayout->addWidget(this->operatorComboBox, 1, 1);
    $mainLayout->addWidget(this->destinationButton, 0, 2, 3, 1);
    $mainLayout->addWidget(this->equalLabel, 1, 3);
    $mainLayout->addWidget(this->resultLabel, 0, 4, 3, 1);
    $mainLayout->setSizeConstraint(Qt4::Layout::SetFixedSize());
    this->setLayout($mainLayout);
# [4]

# [5]
    this->{resultImage} = Qt4::Image($resultSize, Qt4::Image::Format_ARGB32_Premultiplied());

    this->loadImage('images/butterfly.png', \this->{sourceImage}, this->sourceButton);
    this->loadImage('images/checker.png', \this->{destinationImage}, this->destinationButton);

    this->setWindowTitle(this->tr('Image Composition'));
}
# [5]

# [6]
sub chooseSource
{
    this->chooseImage(this->tr('Choose Source Image'), \this->sourceImage, this->sourceButton);
}
# [6]

# [7]
sub chooseDestination
{
    this->chooseImage(this->tr('Choose Destination Image'), \this->destinationImage,
                this->destinationButton);
}
# [7]

# [8]
sub recalculateResult
{
    my $mode = this->currentMode();

    my $painter = Qt4::Painter(this->resultImage);
    $painter->setCompositionMode(Qt4::Painter::CompositionMode_Source());
    $painter->fillRect(this->resultImage->rect(), Qt4::Brush(Qt4::transparent()));
    $painter->setCompositionMode(Qt4::Painter::CompositionMode_SourceOver());
    $painter->drawImage(0, 0, this->destinationImage);
    $painter->setCompositionMode($mode);
    $painter->drawImage(0, 0, this->sourceImage);
    $painter->setCompositionMode(Qt4::Painter::CompositionMode_DestinationOver());
    $painter->fillRect(this->resultImage->rect(), Qt4::Brush(Qt4::white()));
    $painter->end();

    this->resultLabel->setPixmap(Qt4::Pixmap::fromImage(this->resultImage));
}
# [8]

# [9]
sub addOp
{
    my ($mode, $name) = @_;
    this->operatorComboBox->addItem($name, Qt4::Variant(Qt4::Int(${$mode})));
}
# [9]

# [10]
sub chooseImage
{
    my ($title, $image, $button) = @_;
    my $fileName = Qt4::FileDialog::getOpenFileName(this, $title);
    if ($fileName) {
        this->loadImage($fileName, $image, $button);
    }
}
# [10]

# [11]
sub loadImage
{
    my ($fileName, $image, $button) = @_;
    $DB::single=1;
    $$image->load($fileName);

    my $fixedImage = Qt4::Image($resultSize, Qt4::Image::Format_ARGB32_Premultiplied());
    my $painter = Qt4::Painter($fixedImage);
    $painter->setCompositionMode(Qt4::Painter::CompositionMode_Source());
    $painter->fillRect($fixedImage->rect(), Qt4::Brush(Qt4::transparent()));
    $painter->setCompositionMode(Qt4::Painter::CompositionMode_SourceOver());
    $painter->drawImage(this->imagePos($$image), $$image);
    $painter->end();
    $button->setIcon(Qt4::Icon(Qt4::Pixmap::fromImage($fixedImage)));

    $$image = $fixedImage;

    this->recalculateResult();
}
# [11]

# [12]
sub currentMode
{
    return this->operatorComboBox->itemData(this->operatorComboBox->currentIndex())->toInt();
}
# [12]

# [13]
sub imagePos
{
    my ($image) = @_;
    return Qt4::Point(($resultSize->width() - $image->width()) / 2,
                  ($resultSize->height() - $image->height()) / 2);
}
# [13]

1;
