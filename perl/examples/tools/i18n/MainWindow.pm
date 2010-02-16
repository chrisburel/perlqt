package MainWindow;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::MainWindow );

sub centralWidget() {
    return this->{centralWidget};
}

sub label() {
    return this->{label};
}

sub groupBox() {
    return this->{groupBox};
}

sub listWidget() {
    return this->{listWidget};
}

sub perspectiveRadioButton() {
    return this->{perspectiveRadioButton};
}

sub isometricRadioButton() {
    return this->{isometricRadioButton};
}

sub obliqueRadioButton() {
    return this->{obliqueRadioButton};
}

sub fileMenu() {
    return this->{fileMenu};
}

sub exitAction() {
    return this->{exitAction};
}

my $listEntries = [
    ['MainWindow', 'First'],
    ['MainWindow', 'Second'],
    ['MainWindow', 'Third'],
    0
];

sub NEW {
    my ( $class ) = @_;
    $class->SUPER::NEW();
    my $centralWidget = Qt4::Widget();
    this->{centralWidget} = $centralWidget;
    this->setCentralWidget($centralWidget);

    this->createGroupBox();

    my $listWidget = Qt4::ListWidget();
    this->{listWidget} = $listWidget;
    for (my $i = 0; $listEntries->[$i]; ++$i) {
        $listWidget->addItem(qApp->translate($listEntries->[$i]->[0], $listEntries->[$i]->[1]));
    }

    my $mainLayout = Qt4::VBoxLayout();
    $mainLayout->addWidget(this->groupBox);
    $mainLayout->addWidget($listWidget);
    $centralWidget->setLayout($mainLayout);

    my $exitAction = Qt4::Action(this->tr('E&xit'), this);
    this->{exitAction} = $exitAction;
    this->connect($exitAction, SIGNAL 'triggered()', qApp, SLOT 'quit()');

    my $fileMenu = this->menuBar()->addMenu(this->tr('&File'));
    this->{fileMenu} = $fileMenu;
    $fileMenu->setPalette(Qt4::Palette(Qt4::red()));
    $fileMenu->addAction($exitAction);

    this->setWindowTitle(this->tr('Language:').this->tr('English'));
    this->statusBar()->showMessage(this->tr('Internationalization Example'));

    if (this->tr('LTR') eq 'RTL') {
        this->setLayoutDirection(Qt4::RightToLeft());
    }
}

sub createGroupBox {
    my $groupBox = Qt4::GroupBox(this->tr('View'));
    this->{groupBox} = $groupBox;
    my $perspectiveRadioButton = Qt4::RadioButton(this->tr('Perspective'));
    this->{perspectiveRadioButton} = $perspectiveRadioButton;
    my $isometricRadioButton = Qt4::RadioButton(this->tr('Isometric'));
    this->{isometricRadioButton} = $isometricRadioButton;
    my $obliqueRadioButton = Qt4::RadioButton(this->tr('Oblique'));
    this->{obliqueRadioButton} = $obliqueRadioButton;
    $perspectiveRadioButton->setChecked(1);

    my $groupBoxLayout = Qt4::VBoxLayout();
    $groupBoxLayout->addWidget($perspectiveRadioButton);
    $groupBoxLayout->addWidget($isometricRadioButton);
    $groupBoxLayout->addWidget($obliqueRadioButton);
    $groupBox->setLayout($groupBoxLayout);
}

1;
