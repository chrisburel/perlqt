package MainWindow;

use strict;
use warnings;
use blib;

use Qt4;

# [0]
use Qt4::isa qw( Qt4::MainWindow );
use Qt4::slots
    about => [],
    changeStyle => ['bool'],
    changeSize => ['bool'],
    changeSizeBool => [],
    changeIcon => [],
    addImages => [],
    removeAllImages => [];
#use Qt4::debug qw(all);

use IconPreviewArea;
use ImageDelegate;
use IconSizeSpinBox;

sub centralWidget() {
    return this->{centralWidget};
}

sub setCentralWidget($) {
    this->{centralWidget} = shift;
    this->SUPER::setCentralWidget( this->centralWidget );
}


sub previewGroupBox() {
    return this->{previewGroupBox};
}

sub setPreviewGroupBox($) {
    return this->{previewGroupBox} = shift;
}

sub previewArea() {
    return this->{previewArea};
}

sub setPreviewArea($) {
    return this->{previewArea} = shift;
}


sub imagesGroupBox() {
    return this->{imagesGroupBox};
}

sub setImagesGroupBox($) {
    return this->{imagesGroupBox} = shift;
}

sub imagesTable() {
    return this->{imagesTable};
}

sub setImagesTable($) {
    return this->{imagesTable} = shift;
}


sub iconSizeGroupBox() {
    return this->{iconSizeGroupBox};
}

sub setIconSizeGroupBox($) {
    return this->{iconSizeGroupBox} = shift;
}

sub smallRadioButton() {
    return this->{smallRadioButton};
}

sub setSmallRadioButton($) {
    return this->{smallRadioButton} = shift;
}

sub largeRadioButton() {
    return this->{largeRadioButton};
}

sub setLargeRadioButton($) {
    return this->{largeRadioButton} = shift;
}

sub toolBarRadioButton() {
    return this->{toolBarRadioButton};
}

sub setToolBarRadioButton($) {
    return this->{toolBarRadioButton} = shift;
}

sub listViewRadioButton() {
    return this->{listViewRadioButton};
}

sub setListViewRadioButton($) {
    return this->{listViewRadioButton} = shift;
}

sub iconViewRadioButton() {
    return this->{iconViewRadioButton};
}

sub setIconViewRadioButton($) {
    return this->{iconViewRadioButton} = shift;
}

sub tabBarRadioButton() {
    return this->{tabBarRadioButton};
}

sub setTabBarRadioButton($) {
    return this->{tabBarRadioButton} = shift;
}

sub otherRadioButton() {
    return this->{otherRadioButton};
}

sub setOtherRadioButton($) {
    return this->{otherRadioButton} = shift;
}

sub otherSpinBox() {
    return this->{otherSpinBox};
}

sub setOtherSpinBox($) {
    return this->{otherSpinBox} = shift;
}


sub fileMenu() {
    return this->{fileMenu};
}

sub setFileMenu($) {
    return this->{fileMenu} = shift;
}

sub viewMenu() {
    return this->{viewMenu};
}

sub setViewMenu($) {
    return this->{viewMenu} = shift;
}

sub helpMenu() {
    return this->{helpMenu};
}

sub setHelpMenu($) {
    return this->{helpMenu} = shift;
}

sub addImagesAct() {
    return this->{addImagesAct};
}

sub setAddImagesAct($) {
    return this->{addImagesAct} = shift;
}

sub removeAllImagesAct() {
    return this->{removeAllImagesAct};
}

sub setRemoveAllImagesAct($) {
    return this->{removeAllImagesAct} = shift;
}

sub exitAct() {
    return this->{exitAct};
}

sub setExitAct($) {
    return this->{exitAct} = shift;
}

sub guessModeStateAct() {
    return this->{guessModeStateAct};
}

sub setGuessModeStateAct($) {
    return this->{guessModeStateAct} = shift;
}

sub styleActionGroup() {
    return this->{styleActionGroup};
}

sub setStyleActionGroup($) {
    return this->{styleActionGroup} = shift;
}

sub aboutAct() {
    return this->{aboutAct};
}

sub setAboutAct($) {
    return this->{aboutAct} = shift;
}

sub aboutQtAct() {
    return this->{aboutQtAct};
}

sub setAboutQtAct($) {
    return this->{aboutQtAct} = shift;
}

# [0]

# [0]
sub NEW {
    my ( $class ) = @_;
    $class->SUPER::NEW();

    this->setCentralWidget(Qt4::Widget());

    this->createPreviewGroupBox();
    this->createImagesGroupBox();
    this->createIconSizeGroupBox();

    this->createActions();
    this->createMenus();
    this->createContextMenu();

    my $mainLayout = Qt4::GridLayout();
    $mainLayout->addWidget(this->previewGroupBox, 0, 0, 1, 2);
    $mainLayout->addWidget(this->imagesGroupBox, 1, 0);
    $mainLayout->addWidget(this->iconSizeGroupBox, 1, 1);
    this->centralWidget->setLayout($mainLayout);

    this->setWindowTitle(this->tr('Icons'));
    this->checkCurrentStyle();
    this->otherRadioButton->click();

    this->resize(this->minimumSizeHint());
}
# [0]

# [1]
sub about {
    Qt4::MessageBox::about(this, this->tr('About Icons'),
            this->tr('The <b>Icons</b> example illustrates how Qt4 renders an icon in ' .
               'different modes (active, normal, disabled, and selected) and ' .
               'states (on and off) based on a set of images.'));
}
# [1]

# [2]
sub changeStyle {
    my ($checked) = @_;
    if (!$checked) {
        return;
    }

    #my $action = Qt4::Action() = qobject_cast<Qt4::Action *>(sender());
    my $action = this->sender();
# [2] //! [3]
    my $style = Qt4::StyleFactory::create($action->data()->toString());
# [3] //! [4]
    Qt4::Application::setStyle($style);

    this->smallRadioButton->setText(sprintf this->tr('Small (%d x %d)'),
            $style->pixelMetric(Qt4::Style::PM_SmallIconSize(), undef, undef),
            $style->pixelMetric(Qt4::Style::PM_SmallIconSize(), undef, undef));
    this->largeRadioButton->setText(sprintf this->tr('Large (%d x %d)'),
            $style->pixelMetric(Qt4::Style::PM_LargeIconSize(), undef, undef),
            $style->pixelMetric(Qt4::Style::PM_LargeIconSize(), undef, undef));
    this->toolBarRadioButton->setText(sprintf this->tr('Toolbars (%d x %d)'),
            $style->pixelMetric(Qt4::Style::PM_ToolBarIconSize(), undef, undef),
            $style->pixelMetric(Qt4::Style::PM_ToolBarIconSize(), undef, undef));
    this->listViewRadioButton->setText(sprintf this->tr('List views (%d x %d)'),
            $style->pixelMetric(Qt4::Style::PM_ListViewIconSize(), undef, undef),
            $style->pixelMetric(Qt4::Style::PM_ListViewIconSize(), undef, undef));
    this->iconViewRadioButton->setText(sprintf this->tr('Icon views (%d x %d)'),
            $style->pixelMetric(Qt4::Style::PM_IconViewIconSize(), undef, undef),
            $style->pixelMetric(Qt4::Style::PM_IconViewIconSize(), undef, undef));
    this->tabBarRadioButton->setText(sprintf this->tr('Tab bars (%d x %d)'),
            $style->pixelMetric(Qt4::Style::PM_TabBarIconSize(), undef, undef),
            $style->pixelMetric(Qt4::Style::PM_TabBarIconSize(), undef, undef));

    this->changeSize(1);
}
# [4]

# [5]
sub changeSizeBool {
    this->changeSize(1);
}

sub changeSize {
    my ($checked) = @_;
    if (!$checked) {
        return;
    }

    my $extent;

    if (this->otherRadioButton->isChecked()) {
        $extent = this->otherSpinBox->value();
    } else {
        my $metric;

        if (this->smallRadioButton->isChecked()) {
            $metric = Qt4::Style::PM_SmallIconSize();
        } elsif (this->largeRadioButton->isChecked()) {
            $metric = Qt4::Style::PM_LargeIconSize();
        } elsif (this->toolBarRadioButton->isChecked()) {
            $metric = Qt4::Style::PM_ToolBarIconSize();
        } elsif (this->listViewRadioButton->isChecked()) {
            $metric = Qt4::Style::PM_ListViewIconSize();
        } elsif (this->iconViewRadioButton->isChecked()) {
            $metric = Qt4::Style::PM_IconViewIconSize();
        } else {
            $metric = Qt4::Style::PM_TabBarIconSize();
        }
        $extent = Qt4::Application::style()->pixelMetric($metric, undef, undef);
    }
    this->previewArea->setSize(Qt4::Size($extent, $extent));
    this->otherSpinBox->setEnabled(this->otherRadioButton->isChecked());
}
# [5]

# [6]
sub changeIcon {
    my $icon = Qt4::Icon();

    for (my $row = 0; $row < this->imagesTable->rowCount(); ++$row) {
        my $item0 = this->imagesTable->item($row, 0);
        my $item1 = this->imagesTable->item($row, 1);
        my $item2 = this->imagesTable->item($row, 2);

        if ($item0->checkState() == Qt4::Checked()) {
            my $mode;
            if ($item1->text() eq this->tr('Normal')) {
                $mode = Qt4::Icon::Normal();
            } elsif ($item1->text() eq this->tr('Active')) {
                $mode = Qt4::Icon::Active();
            } elsif ($item1->text() eq this->tr('Disabled')) {
                $mode = Qt4::Icon::Disabled();
            } else {
                $mode = Qt4::Icon::Selected();
            }

            my $state;
            if ($item2->text() eq this->tr('On')) {
                $state = Qt4::Icon::On();
            } else {
                $state = Qt4::Icon::Off();
# [6] //! [7]
            }
# [7]

# [8]
            my $fileName = $item0->data(Qt4::UserRole())->toString();
            my $image = Qt4::Image(Qt4::String($fileName));
            if ($image) {
                $icon->addPixmap(Qt4::Pixmap::fromImage($image), $mode, $state);
            }
# [8] //! [9]
        }
# [9] //! [10]
    }
# [10]

# [11]
    this->previewArea->setIcon($icon);
}
# [11]

# [12]
sub addImages {
    my $fileNames = Qt4::FileDialog::getOpenFileNames(this,
                                    this->tr('Open Images'), '',
                                    this->tr('Images (*.png *.xpm *.jpg);;') .
                                    this->tr('All Files (*)'));
    if ( ref $fileNames eq 'ARRAY' ) {
        foreach my $fileName ( @{$fileNames} ) {
            my $row = this->imagesTable->rowCount();
            this->imagesTable->setRowCount($row + 1);
# [12]

# [13]
            my $imageName = Qt4::FileInfo($fileName)->baseName();
# [13] //! [14]
            my $item0 = Qt4::TableWidgetItem($imageName);
            $item0->setData(Qt4::UserRole(), Qt4::Variant(Qt4::String($fileName)));
            $item0->setFlags($item0->flags()&~${Qt4::ItemIsEditable()});
# [14]

# [15]
            my $item1 = Qt4::TableWidgetItem(this->tr('Normal'));
# [15] //! [16]
            my $item2 = Qt4::TableWidgetItem(this->tr('Off'));

            if (this->guessModeStateAct->isChecked()) {
                if ($fileName =~ m/_act/) {
                    $item1->setText(this->tr('Active'));
                } elsif ($fileName =~ m/_dis/) {
                    $item1->setText(this->tr('Disabled'));
                } elsif ($fileName =~ m/_sel/) {
                    $item1->setText(this->tr('Selected'));
                }

                if ($fileName =~ m/_on/) {
                    $item2->setText(this->tr('On'));
                }
# [16] //! [17]
            }
# [17]

# [18]
            this->imagesTable->setItem($row, 0, $item0);
# [18] //! [19]
            this->imagesTable->setItem($row, 1, $item1);
            this->imagesTable->setItem($row, 2, $item2);
            this->imagesTable->openPersistentEditor($item1);
            this->imagesTable->openPersistentEditor($item2);

            $item0->setCheckState(Qt4::Checked());
        }
    }
}
# [19]

# [20]
sub removeAllImages {
    this->imagesTable->setRowCount(0);
    this->changeIcon();
}
# [20]

sub createPreviewGroupBox {
    this->setPreviewGroupBox( Qt4::GroupBox(this->tr('Preview')) );

    this->setPreviewArea( IconPreviewArea() );

    my $layout = Qt4::VBoxLayout();
    $layout->addWidget(this->previewArea);
    this->previewGroupBox->setLayout($layout);
    return;
}

# [21]
sub createImagesGroupBox {
    this->setImagesGroupBox( Qt4::GroupBox(this->tr('Images')) );

    this->setImagesTable( Qt4::TableWidget() );
    this->imagesTable->setSelectionMode(Qt4::AbstractItemView::NoSelection());
    this->imagesTable->setItemDelegate(ImageDelegate(this));
# [21]

# [22]
    my @labels;
# [22] //! [23]
    @labels = (this->tr('Image'), this->tr('Mode'), this->tr('State'));

    this->imagesTable->horizontalHeader()->setDefaultSectionSize(90);
    this->imagesTable->setColumnCount(3);
    this->imagesTable->setHorizontalHeaderLabels(\@labels);
    this->imagesTable->horizontalHeader()->setResizeMode(0, Qt4::HeaderView::Stretch());
    this->imagesTable->horizontalHeader()->setResizeMode(1, Qt4::HeaderView::Fixed());
    this->imagesTable->horizontalHeader()->setResizeMode(2, Qt4::HeaderView::Fixed());
    this->imagesTable->verticalHeader()->hide();
# [23]

# [24]
    this->connect(this->imagesTable, SIGNAL 'itemChanged(QTableWidgetItem *)',
# [24] //! [25]
            this, SLOT 'changeIcon()');

    my $layout = Qt4::VBoxLayout();
    $layout->addWidget(this->imagesTable);
    this->imagesGroupBox->setLayout($layout);
}
# [25]

# [26]
sub createIconSizeGroupBox {
    this->setIconSizeGroupBox( Qt4::GroupBox(this->tr('Icon Size')) );

    this->setSmallRadioButton( Qt4::RadioButton() );
    this->setLargeRadioButton( Qt4::RadioButton() );
    this->setToolBarRadioButton( Qt4::RadioButton() );
    this->setListViewRadioButton( Qt4::RadioButton() );
    this->setIconViewRadioButton( Qt4::RadioButton() );
    this->setTabBarRadioButton( Qt4::RadioButton() );
    this->setOtherRadioButton( Qt4::RadioButton(this->tr('Other:')) );

    this->setOtherSpinBox( IconSizeSpinBox() );
    this->otherSpinBox->setRange(8, 128);
    this->otherSpinBox->setValue(64);
# [26]

# [27]
    this->connect(this->smallRadioButton, SIGNAL 'toggled(bool)',
            this, SLOT 'changeSize(bool)');
    this->connect(this->largeRadioButton, SIGNAL 'toggled(bool)',
            this, SLOT 'changeSize(bool)');
    this->connect(this->toolBarRadioButton, SIGNAL 'toggled(bool)',
            this, SLOT 'changeSize(bool)');
    this->connect(this->listViewRadioButton, SIGNAL 'toggled(bool)',
            this, SLOT 'changeSize(bool)');
    this->connect(this->iconViewRadioButton, SIGNAL 'toggled(bool)',
            this, SLOT 'changeSize(bool)');
    this->connect(this->tabBarRadioButton, SIGNAL 'toggled(bool)',
            this, SLOT 'changeSize(bool)');
    this->connect(this->otherRadioButton, SIGNAL 'toggled(bool)',
            this, SLOT 'changeSize(bool)');
    this->connect(this->otherSpinBox, SIGNAL 'valueChanged(int)', this, SLOT 'changeSizeBool()');

    my $otherSizeLayout = Qt4::HBoxLayout();
    $otherSizeLayout->addWidget(this->otherRadioButton);
    $otherSizeLayout->addWidget(this->otherSpinBox);
    $otherSizeLayout->addStretch();

    my $layout = Qt4::GridLayout();
    $layout->addWidget(this->smallRadioButton, 0, 0);
    $layout->addWidget(this->largeRadioButton, 1, 0);
    $layout->addWidget(this->toolBarRadioButton, 2, 0);
    $layout->addWidget(this->listViewRadioButton, 0, 1);
    $layout->addWidget(this->iconViewRadioButton, 1, 1);
    $layout->addWidget(this->tabBarRadioButton, 2, 1);
    $layout->addLayout($otherSizeLayout, 3, 0, 1, 2);
    $layout->setRowStretch(4, 1);
    this->iconSizeGroupBox->setLayout($layout);
}
# [27]

# [28]
sub createActions {
    this->setAddImagesAct( Qt4::Action(this->tr('&Add Images...'), this) );
    this->addImagesAct->setShortcut(Qt4::KeySequence(this->tr('Ctrl+A')));
    this->connect(this->addImagesAct, SIGNAL 'triggered()', this, SLOT 'addImages()');

    this->setRemoveAllImagesAct( Qt4::Action(this->tr('&Remove All Images'), this) );
    this->removeAllImagesAct->setShortcut( Qt4::KeySequence(this->tr('Ctrl+R')) );
    this->connect(this->removeAllImagesAct, SIGNAL 'triggered()',
            this, SLOT 'removeAllImages()');

    this->setExitAct( Qt4::Action(this->tr('&Quit'), this) );
    this->exitAct->setShortcut( Qt4::KeySequence(this->tr('Ctrl+Q')) );
    this->connect(this->exitAct, SIGNAL 'triggered()', this, SLOT 'close()');

    this->setStyleActionGroup( Qt4::ActionGroup(this) );
    foreach my $styleName ( @{Qt4::StyleFactory::keys()} ) {
        utf8::encode( $styleName );
        my $action = Qt4::Action(this->styleActionGroup);
        $action->setText( sprintf this->tr('%s Style'), $styleName );
        $action->setData(Qt4::Variant(Qt4::String($styleName)));
        $action->setCheckable(1);
        this->connect($action, SIGNAL 'triggered(bool)', this, SLOT 'changeStyle(bool)');
    }

    this->setGuessModeStateAct( Qt4::Action(this->tr('&Guess Image Mode/State'), this) );
    this->guessModeStateAct->setCheckable(1);
    this->guessModeStateAct->setChecked(1);

    this->setAboutAct( Qt4::Action(this->tr('&About'), this) );
    this->connect(this->aboutAct, SIGNAL 'triggered()', this, SLOT 'about()');

    this->setAboutQtAct( Qt4::Action(this->tr('About &Qt'), this) );
    this->connect(this->aboutQtAct, SIGNAL 'triggered()', qApp, SLOT 'aboutQt()');
}
# [28]

# [29]
sub createMenus {
    this->setFileMenu( this->menuBar()->addMenu(this->tr('&File')) );
    this->fileMenu->addAction(this->addImagesAct);
    this->fileMenu->addAction(this->removeAllImagesAct);
    this->fileMenu->addSeparator();
    this->fileMenu->addAction(this->exitAct);

    this->setViewMenu( this->menuBar()->addMenu(this->tr('&View')) );
    foreach my $action ( @{this->styleActionGroup->actions()} ) {
        this->viewMenu->addAction($action);
    }
    this->viewMenu->addSeparator();
    this->viewMenu->addAction(this->guessModeStateAct);

    this->menuBar()->addSeparator();

    this->setHelpMenu( this->menuBar()->addMenu(this->tr('&Help')) );
    this->helpMenu->addAction(this->aboutAct);
    this->helpMenu->addAction(this->aboutQtAct);
}
# [29]

# [30]
sub createContextMenu {
    this->imagesTable->setContextMenuPolicy(Qt4::ActionsContextMenu());
    this->imagesTable->addAction(this->addImagesAct);
    this->imagesTable->addAction(this->removeAllImagesAct);
}
# [30]

# [31]
sub checkCurrentStyle {
    foreach my $action ( @{this->styleActionGroup->actions()} ) {
        my $styleName = $action->data()->toString();
        my $candidate = Qt4::StyleFactory::create($styleName);
        #printf "AppStyle: 0x%x\n", Qt4::_internal::sv_to_ptr(Qt4::Application::style());
        Qt4::_internal::sv_to_ptr(Qt4::Application::style());
        if ($candidate->metaObject()->className()
                eq Qt4::Application::style()->metaObject()->className()) {
            $action->trigger();
            return;
        }
    }
}
# [31]

1;
