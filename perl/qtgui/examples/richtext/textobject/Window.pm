package Window;

use strict;
use warnings;
use Qt4;

#[0]
use Qt4::isa qw( Qt4::Widget );
use constant SvgTextFormat => Qt4::TextFormat::UserObject() + 1;
use constant SvgData => 1;

use Qt4::slots
    insertTextObject => [];
#[0]

use SvgTextObject;

sub NEW
{
    my ($class) = @_;
    $class->SUPER::NEW();
    this->setupGui();
    this->setupTextObject();

    this->setWindowTitle('Text Object Example');
}

#[1]
sub insertTextObject
{
    my $fileName = this->{fileNameLineEdit}->text();
    my $file = Qt4::File($fileName);
    if (!$file->open(Qt4::IODevice::ReadOnly())) {
        Qt4::MessageBox::warning(this, this->tr('Error Opening File'),
                             sprintf this->tr('Could not open \'%s\''), $fileName);
    }

    my $svgData = $file->readAll();
#[1]

#[2]
    my $svgCharFormat = Qt4::TextCharFormat();
    $svgCharFormat->setObjectType(SvgTextFormat);
    my $renderer = Qt4::SvgRenderer($svgData);

    my $svgBufferImage = Qt4::Image($renderer->defaultSize(), Qt4::Image::Format_ARGB32());
    my $painter = Qt4::Painter($svgBufferImage);
    $renderer->render($painter, Qt4::RectF($svgBufferImage->rect()));

    $svgCharFormat->setProperty(SvgData, Qt4::qVariantFromValue($svgBufferImage));

    my $cursor = this->{textEdit}->textCursor();
    $cursor->insertText(Qt4::Char::ObjectReplacementCharacter(), $svgCharFormat);
    this->{textEdit}->setTextCursor($cursor);
}
#[2]

#[3]
sub setupTextObject
{
    my $svgInterface = SvgTextObject();
    this->{textEdit}->document()->documentLayout()->registerHandler(SvgTextFormat, $svgInterface);
}
#[3]

sub setupGui
{
    this->{fileNameLabel} = Qt4::Label(this->tr('Svg File Name:'));
    this->{fileNameLineEdit} = Qt4::LineEdit();
    this->{insertTextObjectButton} = Qt4::PushButton(this->tr('Insert Image'));

    this->{fileNameLineEdit}->setText('./files/heart.svg');
    this->connect(this->{insertTextObjectButton}, SIGNAL 'clicked()',
            this, SLOT 'insertTextObject()');

    my $bottomLayout = Qt4::HBoxLayout();
    $bottomLayout->addWidget(this->{fileNameLabel});
    $bottomLayout->addWidget(this->{fileNameLineEdit});
    $bottomLayout->addWidget(this->{insertTextObjectButton});

    this->{textEdit} = Qt4::TextEdit();

    my $mainLayout = Qt4::VBoxLayout();
    $mainLayout->addWidget(this->{textEdit});
    $mainLayout->addLayout($bottomLayout);

    this->setLayout($mainLayout);
}

1;
