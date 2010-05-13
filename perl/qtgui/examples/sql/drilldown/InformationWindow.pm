package InformationWindow;

use strict;
use warnings;
use Qt4;

# [0]
use Qt4::isa qw( Qt4::Dialog );
use Qt4::signals
    imageChanged => ['int', 'const QString &'];
# [0]

# [1]
use Qt4::slots
    revert => [],
    submit => [],
    enableButtons2 => [],
    enableButtons => ['bool'];
# [1]

# [0]
sub NEW {
    my ($class, $id, $offices, $parent) = @_;
    $class->SUPER::NEW($parent);
# [0] //! [1]
    my $locationLabel = Qt4::Label(this->tr('Location: '));
    my $countryLabel = Qt4::Label(this->tr('Country: '));
    my $descriptionLabel = Qt4::Label(this->tr('Description: '));
    my $imageFileLabel = Qt4::Label(this->tr('Image file: '));

    this->createButtons();

    this->{locationText} = Qt4::Label();
    this->{countryText} = Qt4::Label();
    this->{descriptionEditor} = Qt4::TextEdit();
# [1]

# [2]
    this->{imageFileEditor} = Qt4::ComboBox();
    this->{imageFileEditor}->setModel($offices->relationModel(1));
    this->{imageFileEditor}->setModelColumn($offices->relationModel(1)->fieldIndex('file'));
# [2]

# [3]
    this->{mapper} = Qt4::DataWidgetMapper(this);
    this->{mapper}->setModel($offices);
    this->{mapper}->setSubmitPolicy(Qt4::DataWidgetMapper::ManualSubmit());
    this->{mapper}->setItemDelegate(Qt4::SqlRelationalDelegate(this->{mapper}));
    this->{mapper}->addMapping(this->{imageFileEditor}, 1);
    this->{mapper}->addMapping(this->{locationText}, 2, Qt4::ByteArray('text'));
    this->{mapper}->addMapping(this->{countryText}, 3, Qt4::ByteArray('text'));
    this->{mapper}->addMapping(this->{descriptionEditor}, 4);
    this->{mapper}->setCurrentIndex($id);
# [3]

# [4]
    this->connect(this->{descriptionEditor}, SIGNAL 'textChanged()',
            this, SLOT 'enableButtons2()');
    this->connect(this->{imageFileEditor}, SIGNAL 'currentIndexChanged(int)',
            this, SLOT 'enableButtons2()');

    my $layout = Qt4::GridLayout();
    $layout->addWidget($locationLabel, 0, 0, Qt4::AlignLeft() | Qt4::AlignTop());
    $layout->addWidget($countryLabel, 1, 0, Qt4::AlignLeft() | Qt4::AlignTop());
    $layout->addWidget($imageFileLabel, 2, 0, Qt4::AlignLeft() | Qt4::AlignTop());
    $layout->addWidget($descriptionLabel, 3, 0, Qt4::AlignLeft() | Qt4::AlignTop());
    $layout->addWidget(this->{locationText}, 0, 1);
    $layout->addWidget(this->{countryText}, 1, 1);
    $layout->addWidget(this->{imageFileEditor}, 2, 1);
    $layout->addWidget(this->{descriptionEditor}, 3, 1);
    $layout->addWidget(this->{buttonBox}, 4, 0, 1, 2);
    this->setLayout($layout);

    this->{locationId} = $id;
    this->{displayedImage} = this->{imageFileEditor}->currentText();

    this->setWindowFlags(Qt4::Window());
    this->enableButtons($0);
    this->setWindowTitle(sprintf this->tr('Office: %s'), this->{locationText}->text());
    this->resize(320, this->sizeHint()->height());
}
# [4]

# [5]
sub id
{
    return this->{locationId};
}
# [5]

# [6]
sub revert
{
    this->{mapper}->revert();
    this->enableButtons(0);
}
# [6]

# [7]
sub submit
{
    my $newImage = this->{imageFileEditor}->currentText();

    if (this->{displayedImage} ne $newImage) {
        this->{displayedImage} = $newImage;
        emit imageChanged(this->{locationId}, $newImage);
    }

    this->{mapper}->submit();
    this->{mapper}->setCurrentIndex(this->{locationId});

    this->enableButtons(0);
}
# [7]

# [8]
sub createButtons
{
    this->{closeButton} = Qt4::PushButton(this->tr('&Close'));
    this->{revertButton} = Qt4::PushButton(this->tr('&Revert'));
    this->{submitButton} = Qt4::PushButton(this->tr('&Submit'));

    this->{closeButton}->setDefault(1);

    this->connect(this->{closeButton}, SIGNAL 'clicked()', this, SLOT 'close()');
    this->connect(this->{revertButton}, SIGNAL 'clicked()', this, SLOT 'revert()');
    this->connect(this->{submitButton}, SIGNAL 'clicked()', this, SLOT 'submit()');
# [8]

# [9]
    this->{buttonBox} = Qt4::DialogButtonBox();
    this->{buttonBox}->addButton(this->{submitButton}, Qt4::DialogButtonBox::ResetRole());
    this->{buttonBox}->addButton(this->{revertButton}, Qt4::DialogButtonBox::ResetRole());
    this->{buttonBox}->addButton(this->{closeButton}, Qt4::DialogButtonBox::RejectRole());
}
# [9]

sub enableButtons2 {
    this->enableButtons(1);
}

# [10]
sub enableButtons
{
    my ($enable) = @_;
    this->{revertButton}->setEnabled($enable);
    this->{submitButton}->setEnabled($enable);
}
# [10]

1;
