package ConfigurationPage;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Widget );

sub NEW {
    shift->SUPER::NEW( @_ );
    my $configGroup = Qt4::GroupBox(this->tr('Server configuration'));

    my $serverLabel = Qt4::Label(this->tr('Server:'));
    my $serverCombo = Qt4::ComboBox();
    $serverCombo->addItem(this->tr('Qt Software (Australia)'));
    $serverCombo->addItem(this->tr('Qt Software (Germany)'));
    $serverCombo->addItem(this->tr('Qt Software (Norway)'));
    $serverCombo->addItem(this->tr('Qt Software (People\'s Republic of China)'));
    $serverCombo->addItem(this->tr('Qt Software (USA)'));

    my $serverLayout = Qt4::HBoxLayout();
    $serverLayout->addWidget($serverLabel);
    $serverLayout->addWidget($serverCombo);

    my $configLayout = Qt4::VBoxLayout();
    $configLayout->addLayout($serverLayout);
    $configGroup->setLayout($configLayout);

    my $mainLayout = Qt4::VBoxLayout();
    $mainLayout->addWidget($configGroup);
    $mainLayout->addStretch(1);
    this->setLayout($mainLayout);
}

package UpdatePage;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Widget );

sub NEW {
    shift->SUPER::NEW( @_ );
    my $updateGroup = Qt4::GroupBox(this->tr('Package selection'));
    my $systemCheckBox = Qt4::CheckBox(this->tr('Update system'));
    my $appsCheckBox = Qt4::CheckBox(this->tr('Update applications'));
    my $docsCheckBox = Qt4::CheckBox(this->tr('Update documentation'));

    my $packageGroup = Qt4::GroupBox(this->tr('Existing packages'));

    my $packageList = Qt4::ListWidget();
    my $qtItem = Qt4::ListWidgetItem($packageList);
    $qtItem->setText(this->tr('Qt'));
    my $qsaItem = Qt4::ListWidgetItem($packageList);
    $qsaItem->setText(this->tr('QSA'));
    my $teamBuilderItem = Qt4::ListWidgetItem($packageList);
    $teamBuilderItem->setText(this->tr('Teambuilder'));

    my $startUpdateButton = Qt4::PushButton(this->tr('Start update'));

    my $updateLayout = Qt4::VBoxLayout();
    $updateLayout->addWidget($systemCheckBox);
    $updateLayout->addWidget($appsCheckBox);
    $updateLayout->addWidget($docsCheckBox);
    $updateGroup->setLayout($updateLayout);

    my $packageLayout = Qt4::VBoxLayout();
    $packageLayout->addWidget($packageList);
    $packageGroup->setLayout($packageLayout);

    my $mainLayout = Qt4::VBoxLayout();
    $mainLayout->addWidget($updateGroup);
    $mainLayout->addWidget($packageGroup);
    $mainLayout->addSpacing(12);
    $mainLayout->addWidget($startUpdateButton);
    $mainLayout->addStretch(1);
    this->setLayout($mainLayout);
}

package QueryPage;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Widget );

sub NEW {
    shift->SUPER::NEW( @_ );
    my $packagesGroup = Qt4::GroupBox(this->tr('Look for packages'));

    my $nameLabel = Qt4::Label(this->tr('Name:'));
    my $nameEdit = Qt4::LineEdit();

    my $dateLabel = Qt4::Label(this->tr('Released after:'));
    my $dateEdit = Qt4::DateTimeEdit(Qt4::Date::currentDate());

    my $releasesCheckBox = Qt4::CheckBox(this->tr('Releases'));
    my $upgradesCheckBox = Qt4::CheckBox(this->tr('Upgrades'));

    my $hitsSpinBox = Qt4::SpinBox();
    $hitsSpinBox->setPrefix(this->tr('Return up to '));
    $hitsSpinBox->setSuffix(this->tr(' results'));
    $hitsSpinBox->setSpecialValueText(this->tr('Return only the first result'));
    $hitsSpinBox->setMinimum(1);
    $hitsSpinBox->setMaximum(100);
    $hitsSpinBox->setSingleStep(10);

    my $startQueryButton = Qt4::PushButton(this->tr('Start query'));

    my $packagesLayout = Qt4::GridLayout();
    $packagesLayout->addWidget($nameLabel, 0, 0);
    $packagesLayout->addWidget($nameEdit, 0, 1);
    $packagesLayout->addWidget($dateLabel, 1, 0);
    $packagesLayout->addWidget($dateEdit, 1, 1);
    $packagesLayout->addWidget($releasesCheckBox, 2, 0);
    $packagesLayout->addWidget($upgradesCheckBox, 3, 0);
    $packagesLayout->addWidget($hitsSpinBox, 4, 0, 1, 2);
    $packagesGroup->setLayout($packagesLayout);

    my $mainLayout = Qt4::VBoxLayout();
    $mainLayout->addWidget($packagesGroup);
    $mainLayout->addSpacing(12);
    $mainLayout->addWidget($startQueryButton);
    $mainLayout->addStretch(1);
    this->setLayout($mainLayout);
}

1;
