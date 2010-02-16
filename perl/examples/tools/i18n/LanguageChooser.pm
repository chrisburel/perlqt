package LanguageChooser;

use strict;
use warnings;
use blib;

# Since we lack qHash, use md5
use Digest::MD5 qw(md5_hex);

use Qt4;
use Qt4::isa qw( Qt4::Dialog );
use Qt4::slots
    checkBoxToggled => [],
    showAll => [],
    hideAll => [];
use MainWindow;

sub groupBox() {
    return this->{groupBox};
}

sub buttonBox() {
    return this->{buttonBox};
}

sub showAllButton() {
    return this->{showAllButton};
}

sub hideAllButton() {
    return this->{hideAllButton};
}

sub qmFileForCheckBoxMap() {
    return this->{qmFileForCheckBoxMap};
}

sub mainWindowForCheckBoxMap() {
    return this->{mainWindowForCheckBoxMap};
}

sub NEW {
    my ( $class, $parent ) = @_;
    $class->SUPER::NEW( $parent, Qt4::WindowStaysOnTopHint());
    my $groupBox = Qt4::GroupBox('Languages');
    this->{groupBox} = $groupBox;

    my $groupBoxLayout = Qt4::GridLayout();

    my $qmFiles = this->findQmFiles();
    for (my $i = 0; $i < $#{$qmFiles}; ++$i) {
        my $languageName = this->languageName($qmFiles->[$i]);
        my $checkBox = Qt4::CheckBox( $languageName );
        $checkBox->setObjectName( $languageName );
        this->{qmFileForCheckBoxMap}->{$languageName} = [$checkBox, $qmFiles->[$i]];
        this->connect($checkBox, SIGNAL 'toggled(bool)', this, SLOT 'checkBoxToggled()');
        $groupBoxLayout->addWidget($checkBox, $i / 2, $i % 2);
    }
    $groupBox->setLayout($groupBoxLayout);

    my $buttonBox = Qt4::DialogButtonBox();
    this->{buttonBox} = $buttonBox;

    my $showAllButton = buttonBox->addButton('Show All',
                                         Qt4::DialogButtonBox::ActionRole());
    this->{showAllButton} = $showAllButton;
    my $hideAllButton = buttonBox->addButton('Hide All',
                                         Qt4::DialogButtonBox::ActionRole());
    this->{hideAllButton} = $hideAllButton;

    this->connect($showAllButton, SIGNAL 'clicked()', this, SLOT 'showAll()');
    this->connect($hideAllButton, SIGNAL 'clicked()', this, SLOT 'hideAll()');

    my $mainLayout = Qt4::VBoxLayout();
    $mainLayout->addWidget($groupBox);
    $mainLayout->addWidget($buttonBox);
    this->setLayout($mainLayout);

    this->setWindowTitle('I18N');
}

sub eventFilter {
    my ($object, $event) = @_;
    if ($event->type() == Qt4::Event::Close()) {
        # TODO Write support for qobject_cast
        my $window = bless $object, ' MainWindow';
        if ($window->inherits( 'QMainWindow' ) ) {
            my $checkBox = this->mainWindowForCheckBoxMap->{$window->objectName()}->{checkBox};
            if ($checkBox) {
                $checkBox->setChecked(0);
            }
        }
    }
    return this->SUPER::eventFilter($object, $event);
}

sub closeEvent {
    qApp->quit();
}

sub checkBoxToggled {
    my $checkBox = this->sender();
    if( $checkBox->inherits( 'QCheckBox' ) ) {
        $checkBox = bless $checkBox, ' Qt4::CheckBox';
    }
    else {
        return;
    }
    my $window = this->{mainWindowForCheckBoxMap}->{$checkBox->objectName()}->{window};
    if (!$window) {
        my $translator = Qt4::Translator();
        $translator->load(this->qmFileForCheckBoxMap->{$checkBox->objectName()}->[1]);
        qApp->installTranslator($translator);

        $window = MainWindow();
        $window->setObjectName( $checkBox->objectName() );
        $window->setPalette(Qt4::Palette(this->colorForLanguage($checkBox->text())));

        $window->installEventFilter(this);
        this->mainWindowForCheckBoxMap->{$checkBox->objectName()}->{window} = $window;
        this->mainWindowForCheckBoxMap->{$checkBox->objectName()}->{checkBox} = $checkBox;
    }
    $window->setVisible($checkBox->isChecked());
}

sub showAll {
    foreach my $language (keys %{this->qmFileForCheckBoxMap} ) {
        my $checkBox = this->qmFileForCheckBoxMap->{$language}->[0];
        $checkBox->setChecked(1);
    }
}

sub hideAll {
    foreach my $language ( keys %{this->qmFileForCheckBoxMap} ) {
        my $checkBox = this->qmFileForCheckBoxMap->{$language}->[0];
        $checkBox->setChecked(0);
    }
}

sub findQmFiles {
    my $dir = Qt4::Dir('translations');
    my $fileNames = $dir->entryList(['*.qm'], Qt4::Dir::Files(), Qt4::Dir::Name());
    return [] unless ref $fileNames eq 'ARRAY';
    foreach my $i ( @{$fileNames} ) {
        $i = $dir->filePath($i);
    }
    return $fileNames;
}

sub languageName {
    my ($qmFile) = @_;
    my $translator = Qt4::Translator();
    $translator->load($qmFile);

    return $translator->translate('MainWindow', 'English');
}

sub colorForLanguage {
    my ($language) = @_;
    # Since we lack qHash, use md5
    utf8::encode($language);
    my $hashValue = md5_hex($language);
    $hashValue = eval( '0x'.substr( $hashValue, 0, 6 ) );

    my $red = 156 + ($hashValue & 0x3F);
    my $green = 156 + (($hashValue >> 6) & 0x3F);
    my $blue = 156 + (($hashValue >> 12) & 0x3F);
    return Qt4::Color($red, $green, $blue);
}

1;
