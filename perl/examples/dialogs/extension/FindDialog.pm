package FindDialog;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Dialog );

# [0]
sub NEW {
    shift->SUPER::NEW(@_);
    my $label = Qt4::Label(this->tr("Find &what:"));
    my $lineEdit = Qt4::LineEdit();
    $label->setBuddy($lineEdit);

    my $caseCheckBox = Qt4::CheckBox(this->tr("Match &case"));
    my $fromStartCheckBox = Qt4::CheckBox(this->tr("Search from &start"));
    $fromStartCheckBox->setChecked(1);

# [1]
    my $findButton = Qt4::PushButton(this->tr("&Find"));
    $findButton->setDefault(1);

    my $moreButton = Qt4::PushButton(this->tr("&More"));
    $moreButton->setCheckable(1);
# [0]
    $moreButton->setAutoDefault(0);

    my $buttonBox = Qt4::DialogButtonBox(Qt4::Vertical());
    $buttonBox->addButton($findButton, Qt4::DialogButtonBox::ActionRole());
    $buttonBox->addButton($moreButton, Qt4::DialogButtonBox::ActionRole());
# [1]

# [2]
    my $extension = Qt4::Widget();

    my $wholeWordsCheckBox = Qt4::CheckBox(this->tr("&Whole words"));
    my $backwardCheckBox = Qt4::CheckBox(this->tr("Search &backward"));
    my $searchSelectionCheckBox = Qt4::CheckBox(this->tr("Search se&lection"));
# [2]

# [3]
    this->connect($moreButton, SIGNAL 'toggled(bool)', $extension, SLOT 'setVisible(bool)');

    my $extensionLayout = Qt4::VBoxLayout();
    $extensionLayout->setMargin(0);
    $extensionLayout->addWidget($wholeWordsCheckBox);
    $extensionLayout->addWidget($backwardCheckBox);
    $extensionLayout->addWidget($searchSelectionCheckBox);
    $extension->setLayout($extensionLayout);
# [3]

# [4]
    my $topLeftLayout = Qt4::HBoxLayout();
    $topLeftLayout->addWidget($label);
    $topLeftLayout->addWidget($lineEdit);

    my $leftLayout = Qt4::VBoxLayout();
    $leftLayout->addLayout($topLeftLayout);
    $leftLayout->addWidget($caseCheckBox);
    $leftLayout->addWidget($fromStartCheckBox);
    $leftLayout->addStretch(1);

    my $mainLayout = Qt4::GridLayout();
    $mainLayout->setSizeConstraint(Qt4::Layout::SetFixedSize());
    $mainLayout->addLayout($leftLayout, 0, 0);
    $mainLayout->addWidget($buttonBox, 0, 1);
    $mainLayout->addWidget($extension, 1, 0, 1, 2);
    this->setLayout($mainLayout);

    this->setWindowTitle(this->tr("Extension"));
# [4] //! [5]
    $extension->hide();
}
# [5]

1;
