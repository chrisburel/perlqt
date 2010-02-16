package Dialog;

use strict;
use warnings;
use Qt4;
# [0]
use Qt4::isa qw( Qt4::Dialog );
use constant {
    NumGridRows => 3,
    NumButtons => 4
};

sub menuBar() {
    return this->{menuBar};
}

sub horizontalGroupBox() {
    return this->{horizontalGroupBox};
}

sub gridGroupBox() {
    return this->{gridGroupBox};
}

sub formGroupBox() {
    return this->{formGroupBox};
}

sub smallEditor() {
    return this->{smallEditor};
}

sub bigEditor() {
    return this->{bigEditor};
}

sub labels() {
    return this->{labels};
}

sub lineEdits() {
    return this->{lineEdits};
}

sub buttons() {
    return this->{buttons};
}

sub buttonBox() {
    return this->{buttonBox};
}

sub fileMenu() {
    return this->{fileMenu};
}

sub exitAction() {
    return this->{exitAction};
}
# [0]

# [0]
sub NEW
{
    my ($class) = @_;
    $class->SUPER::NEW();
    this->createMenu();
    this->createHorizontalGroupBox();
    this->createGridGroupBox();
    this->createFormGroupBox();
# [0]

# [1]
    this->{bigEditor} = Qt4::TextEdit();
    this->bigEditor->setPlainText(this->tr('This widget takes up all the remaining space ' .
                               'in the top-level layout.'));

    this->{buttonBox} = Qt4::DialogButtonBox(Qt4::DialogButtonBox::Ok()
                                     | Qt4::DialogButtonBox::Cancel());

    this->connect(this->buttonBox, SIGNAL 'accepted()', this, SLOT 'accept()');
    this->connect(this->buttonBox, SIGNAL 'rejected()', this, SLOT 'reject()');
# [1]

# [2]
    my $mainLayout = Qt4::VBoxLayout();
# [2] //! [3]
    $mainLayout->setMenuBar(this->menuBar);
# [3] //! [4]
    $mainLayout->addWidget(this->horizontalGroupBox);
    $mainLayout->addWidget(this->gridGroupBox);
    $mainLayout->addWidget(this->formGroupBox);
    $mainLayout->addWidget(this->bigEditor);
    $mainLayout->addWidget(this->buttonBox);
# [4] //! [5]
    this->setLayout($mainLayout);

    this->setWindowTitle(this->tr('Basic Layouts'));
}
# [5]

# [6]
sub createMenu
{
    this->{menuBar} = Qt4::MenuBar();

    this->{fileMenu} = Qt4::Menu(this->tr('&File'), this);
    this->{exitAction} = this->fileMenu->addAction(this->tr('E&xit'));
    this->menuBar->addMenu(this->fileMenu);

    this->connect(this->exitAction, SIGNAL 'triggered()', this, SLOT 'accept()');
}
# [6]

# [7]
sub createHorizontalGroupBox
{
    this->{horizontalGroupBox} = Qt4::GroupBox(this->tr('Horizontal layout'));
    my $layout = Qt4::HBoxLayout();

    this->{buttons} = [];
    for (my $i = 0; $i < NumButtons; ++$i) {
        this->buttons->[$i] = Qt4::PushButton(sprintf this->tr('Button %s'), $i + 1);
        $layout->addWidget(this->buttons->[$i]);
    }
    this->horizontalGroupBox->setLayout($layout);
}
# [7]

# [8]
sub createGridGroupBox
{
    this->{gridGroupBox} = Qt4::GroupBox(this->tr('Grid layout'));
# [8]
    my $layout = Qt4::GridLayout();

# [9]
    this->{labels} = [];
    this->{lineEdits} = [];
    for (my $i = 0; $i < NumGridRows; ++$i) {
        this->labels->[$i] = Qt4::Label( sprintf this->tr('Line %s'), $i + 1);
        this->lineEdits->[$i] = Qt4::LineEdit();
        $layout->addWidget(this->labels->[$i], $i + 1, 0);
        $layout->addWidget(this->lineEdits->[$i], $i + 1, 1);
    }

# [9] //! [10]
    this->{smallEditor} = Qt4::TextEdit();
    this->smallEditor->setPlainText(this->tr('This widget takes up about two thirds of the ' .
                                 'grid layout.'));
    $layout->addWidget(this->smallEditor, 0, 2, 4, 1);
# [10]

# [11]
    $layout->setColumnStretch(1, 10);
    $layout->setColumnStretch(2, 20);
    this->gridGroupBox->setLayout($layout);
}
# [11]

# [12]
sub createFormGroupBox
{
    this->{formGroupBox} = Qt4::GroupBox(this->tr('Form layout'));
    my $layout = Qt4::FormLayout();
    $layout->addRow(Qt4::Label(this->tr('Line 1:')), Qt4::LineEdit());
    $layout->addRow(Qt4::Label(this->tr('Line 2, long text:')), Qt4::ComboBox());
    $layout->addRow(Qt4::Label(this->tr('Line 3:')), Qt4::SpinBox());
    this->formGroupBox->setLayout($layout);
}
# [12]

1;
