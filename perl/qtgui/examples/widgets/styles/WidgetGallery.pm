package WidgetGallery;

use strict;
use warnings;
use blib;

use Qt4;
# [0]
use Qt4::isa qw( Qt4::Dialog );
use Qt4::slots
    changeStyle => ['const QString &'],
    changePalette => [],
    advanceProgressBar => [];
#use NorwegianWoodStyle;

sub originalPalette() {
    return this->{originalPalette};
}

sub styleLabel() {
    return this->{styleLabel};
}

sub styleComboBox() {
    return this->{styleComboBox};
}

sub useStylePaletteCheckBox() {
    return this->{useStylePaletteCheckBox};
}

sub disableWidgetsCheckBox() {
    return this->{disableWidgetsCheckBox};
}

# [0]
sub topLeftGroupBox() {
    return this->{topLeftGroupBox};
}

sub radioButton1() {
    return this->{radioButton1};
}

sub radioButton2() {
    return this->{radioButton2};
}

sub radioButton3() {
    return this->{radioButton3};
}

sub checkBox() {
    return this->{checkBox};
}

sub topRightGroupBox() {
    return this->{topRightGroupBox};
}

sub defaultPushButton() {
    return this->{defaultPushButton};
}

sub togglePushButton() {
    return this->{togglePushButton};
}

sub flatPushButton() {
    return this->{flatPushButton};
}

sub bottomLeftTabWidget() {
    return this->{bottomLeftTabWidget};
}

sub tableWidget() {
    return this->{tableWidget};
}

sub textEdit() {
    return this->{textEdit};
}

sub bottomRightGroupBox() {
    return this->{bottomRightGroupBox};
}

sub lineEdit() {
    return this->{lineEdit};
}

sub spinBox() {
    return this->{spinBox};
}

sub dateTimeEdit() {
    return this->{dateTimeEdit};
}

sub slider() {
    return this->{slider};
}

sub scrollBar() {
    return this->{scrollBar};
}

sub dial() {
    return this->{dial};
}

sub progressBar() {
    return this->{progressBar};
}

# [0]
sub NEW {
    my ($class, $parent) = @_;
    $class->SUPER::NEW( $parent );
    this->{originalPalette} = Qt4::Application::palette();

    this->{styleComboBox} = Qt4::ComboBox();
    this->styleComboBox->addItem('NorwegianWood');
    this->styleComboBox->addItems(Qt4::StyleFactory::keys());

    this->{styleLabel} = Qt4::Label(this->tr('&Style:'));
    this->styleLabel->setBuddy(this->styleComboBox);

    this->{useStylePaletteCheckBox} = Qt4::CheckBox(this->tr('&Use style\'s standard palette'));
    this->useStylePaletteCheckBox->setChecked(1);

    this->{disableWidgetsCheckBox} = Qt4::CheckBox(this->tr('&Disable widgets'));

    this->createTopLeftGroupBox();
    this->createTopRightGroupBox();
    this->createBottomLeftTabWidget();
    this->createBottomRightGroupBox();
    this->createProgressBar();
# [0]

# [1]
    this->connect(this->styleComboBox, SIGNAL 'activated(const QString &)',
# [1] //! [2]
            this, SLOT 'changeStyle(const QString &)');
    this->connect(this->useStylePaletteCheckBox, SIGNAL 'toggled(bool)',
            this, SLOT 'changePalette()');
    this->connect(this->disableWidgetsCheckBox, SIGNAL 'toggled(bool)',
            this->topLeftGroupBox, SLOT 'setDisabled(bool)');
    this->connect(this->disableWidgetsCheckBox, SIGNAL 'toggled(bool)',
            this->topRightGroupBox, SLOT 'setDisabled(bool)');
    this->connect(this->disableWidgetsCheckBox, SIGNAL 'toggled(bool)',
            this->bottomLeftTabWidget, SLOT 'setDisabled(bool)');
    this->connect(this->disableWidgetsCheckBox, SIGNAL 'toggled(bool)',
            this->bottomRightGroupBox, SLOT 'setDisabled(bool)');
# [2]

# [3]
    my $topLayout = Qt4::HBoxLayout();
# [3] //! [4]
    $topLayout->addWidget(this->styleLabel);
    $topLayout->addWidget(this->styleComboBox);
    $topLayout->addStretch(1);
    $topLayout->addWidget(this->useStylePaletteCheckBox);
    $topLayout->addWidget(this->disableWidgetsCheckBox);

    my $mainLayout = Qt4::GridLayout();
    $mainLayout->addLayout($topLayout, 0, 0, 1, 2);
    $mainLayout->addWidget(this->topLeftGroupBox, 1, 0);
    $mainLayout->addWidget(this->topRightGroupBox, 1, 1);
    $mainLayout->addWidget(this->bottomLeftTabWidget, 2, 0);
    $mainLayout->addWidget(this->bottomRightGroupBox, 2, 1);
    $mainLayout->addWidget(this->progressBar, 3, 0, 1, 2);
    $mainLayout->setRowStretch(1, 1);
    $mainLayout->setRowStretch(2, 1);
    $mainLayout->setColumnStretch(0, 1);
    $mainLayout->setColumnStretch(1, 1);
    this->setLayout($mainLayout);

    this->setWindowTitle(this->tr('Styles'));
    this->changeStyle('NorwegianWood');
}
# [4]

# [5]
sub changeStyle {
# [5] //! [6]
    my ($styleName) = @_;
    if ($styleName eq 'NorwegianWood') {
        #Qt4::Application::setStyle(NorwegianWoodStyle());
    } else {
        Qt4::Application::setStyle(Qt4::StyleFactory::create($styleName));
    }
    this->changePalette();
}
# [6]

# [7]
sub changePalette {
# [7] //! [8]
    if (this->useStylePaletteCheckBox->isChecked()) {
        my $palette = Qt4::Application::style()->standardPalette();
        Qt4::Application::setPalette($palette);
    }
    else {
        Qt4::Application::setPalette(this->originalPalette);
    }
}
# [8]

# [9]
sub advanceProgressBar {
# [9] //! [10]
    my $curVal = this->progressBar->value();
    my $maxVal = this->progressBar->maximum();
    this->progressBar->setValue($curVal + ($maxVal - $curVal) / 100);
}
# [10]

# [11]
sub createTopLeftGroupBox {
# [11] //! [12]
    this->{topLeftGroupBox} = Qt4::GroupBox(this->tr('Group 1'));

    this->{radioButton1} = Qt4::RadioButton(this->tr('Radio button 1'));
    this->{radioButton2} = Qt4::RadioButton(this->tr('Radio button 2'));
    this->{radioButton3} = Qt4::RadioButton(this->tr('Radio button 3'));
    this->radioButton1->setChecked(1);

    this->{checkBox} = Qt4::CheckBox(this->tr('Tri-state check box'));
    this->checkBox->setTristate(1);
    this->checkBox->setCheckState(Qt4::PartiallyChecked());

    my $layout = Qt4::VBoxLayout();
    $layout->addWidget(this->radioButton1);
    $layout->addWidget(this->radioButton2);
    $layout->addWidget(this->radioButton3);
    $layout->addWidget(this->checkBox);
    $layout->addStretch(1);
    this->topLeftGroupBox->setLayout($layout);
}
# [12]

sub createTopRightGroupBox {
    this->{topRightGroupBox} = Qt4::GroupBox(this->tr('Group 2'));

    this->{defaultPushButton} = Qt4::PushButton(this->tr('Default Push Button'));
    this->defaultPushButton->setDefault(1);

    this->{togglePushButton} = Qt4::PushButton(this->tr('Toggle Push Button'));
    this->togglePushButton->setCheckable(1);
    this->togglePushButton->setChecked(1);

    this->{flatPushButton} = Qt4::PushButton(this->tr('Flat Push Button'));
    this->flatPushButton->setFlat(1);

    my $layout = Qt4::VBoxLayout();
    $layout->addWidget(this->defaultPushButton);
    $layout->addWidget(this->togglePushButton);
    $layout->addWidget(this->flatPushButton);
    $layout->addStretch(1);
    this->topRightGroupBox->setLayout($layout);
}

sub createBottomLeftTabWidget {
    this->{bottomLeftTabWidget} = Qt4::TabWidget();
    this->bottomLeftTabWidget->setSizePolicy(Qt4::SizePolicy::Preferred(),
                                       Qt4::SizePolicy::Ignored());

    my $tab1 = Qt4::Widget();
    this->{tableWidget} = Qt4::TableWidget(10, 10);

    my $tab1hbox = Qt4::HBoxLayout();
    $tab1hbox->setMargin(5);
    $tab1hbox->addWidget(this->tableWidget);
    $tab1->setLayout($tab1hbox);

    my $tab2 = Qt4::Widget();
    this->{textEdit} = Qt4::TextEdit();

    this->textEdit->setPlainText(this->tr("Twinkle, twinkle, little star,\n" .
                              "How I wonder what you are.\n" .
                              "Up above the world so high,\n" .
                              "Like a diamond in the sky.\n" .
                              "Twinkle, twinkle, little star,\n" .
                              "How I wonder what you are!\n"));
                     
    my $tab2hbox = Qt4::HBoxLayout();
    $tab2hbox->setMargin(5);
    $tab2hbox->addWidget(this->textEdit);
    $tab2->setLayout($tab2hbox);

    this->bottomLeftTabWidget->addTab($tab1, this->tr('&Table'));
    this->bottomLeftTabWidget->addTab($tab2, this->tr('Text &Edit'));
}

sub createBottomRightGroupBox {
    this->{bottomRightGroupBox} = Qt4::GroupBox(this->tr('Group 3'));
    this->bottomRightGroupBox->setCheckable(1);
    this->bottomRightGroupBox->setChecked(1);

    this->{lineEdit} = Qt4::LineEdit('s3cRe7');
    this->lineEdit->setEchoMode(Qt4::LineEdit::Password());

    this->{spinBox} = Qt4::SpinBox(this->bottomRightGroupBox);
    this->spinBox->setValue(50);

    this->{dateTimeEdit} = Qt4::DateTimeEdit(this->bottomRightGroupBox);
    this->dateTimeEdit->setDateTime(Qt4::DateTime::currentDateTime());

    this->{slider} = Qt4::Slider(Qt4::Horizontal(), this->bottomRightGroupBox);
    this->slider->setValue(40);

    this->{scrollBar} = Qt4::ScrollBar(Qt4::Horizontal(), this->bottomRightGroupBox);
    this->scrollBar->setValue(60);

    this->{dial} = Qt4::Dial(this->bottomRightGroupBox);
    this->dial->setValue(30);
    this->dial->setNotchesVisible(1);

    my $layout = Qt4::GridLayout();
    $layout->addWidget(this->lineEdit, 0, 0, 1, 2);
    $layout->addWidget(this->spinBox, 1, 0, 1, 2);
    $layout->addWidget(this->dateTimeEdit, 2, 0, 1, 2);
    $layout->addWidget(this->slider, 3, 0);
    $layout->addWidget(this->scrollBar, 4, 0);
    $layout->addWidget(this->dial, 3, 1, 2, 1);
    $layout->setRowStretch(5, 1);
    this->bottomRightGroupBox->setLayout($layout);
}

# [13]
sub createProgressBar {
    this->{progressBar} = Qt4::ProgressBar();
    this->progressBar->setRange(0, 10000);
    this->progressBar->setValue(0);

    my $timer = Qt4::Timer(this);
    this->connect($timer, SIGNAL 'timeout()', this, SLOT 'advanceProgressBar()');
    $timer->start(1000);
}
# [13]

1;
