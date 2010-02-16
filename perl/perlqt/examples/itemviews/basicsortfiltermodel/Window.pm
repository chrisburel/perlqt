package Window;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Widget );
use Qt4::slots
    filterRegExpChanged => [],
    filterColumnChanged => [],
    sortChanged => [];

sub NEW {
    shift->SUPER::NEW();
    my $proxyModel = Qt4::SortFilterProxyModel();
    this->{proxyModel} = $proxyModel;
    $proxyModel->setDynamicSortFilter(1);

    my $sourceGroupBox = Qt4::GroupBox(this->tr('Original Model'));
    my $proxyGroupBox = Qt4::GroupBox(this->tr('Sorted/Filtered Model'));

    my $sourceView = Qt4::TreeView();
    this->{sourceView} = $sourceView;
    $sourceView->setRootIsDecorated(0);
    $sourceView->setAlternatingRowColors(1);

    my $proxyView = Qt4::TreeView();
    $proxyView->setRootIsDecorated(0);
    $proxyView->setAlternatingRowColors(1);
    $proxyView->setModel($proxyModel);
    $proxyView->setSortingEnabled(1);

    my $sortCaseSensitivityCheckBox = Qt4::CheckBox(this->tr('Case sensitive sorting'));
    this->{sortCaseSensitivityCheckBox} = $sortCaseSensitivityCheckBox;
    my $filterCaseSensitivityCheckBox = Qt4::CheckBox(this->tr('Case sensitive filter'));
    this->{filterCaseSensitivityCheckBox} = $filterCaseSensitivityCheckBox;

    my $filterPatternLineEdit = Qt4::LineEdit();
    this->{filterPatternLineEdit} = $filterPatternLineEdit;
    my $filterPatternLabel = Qt4::Label(this->tr('&Filter pattern:'));
    $filterPatternLabel->setBuddy($filterPatternLineEdit);

    my $filterSyntaxComboBox = Qt4::ComboBox();
    this->{filterSyntaxComboBox} = $filterSyntaxComboBox;
    $filterSyntaxComboBox->addItem(this->tr('Regular expression'), Qt4::Variant(Qt4::RegExp::RegExp()));
    $filterSyntaxComboBox->addItem(this->tr('Wildcard'), Qt4::Variant(Qt4::RegExp::Wildcard()));
    $filterSyntaxComboBox->addItem(this->tr('Fixed string'), Qt4::Variant(Qt4::RegExp::FixedString()));
    my $filterSyntaxLabel = Qt4::Label(this->tr('Filter &syntax:'));
    $filterSyntaxLabel->setBuddy($filterSyntaxComboBox);

    my $filterColumnComboBox = Qt4::ComboBox();
    this->{filterColumnComboBox} = $filterColumnComboBox;
    $filterColumnComboBox->addItem(this->tr('Subject'));
    $filterColumnComboBox->addItem(this->tr('Sender'));
    $filterColumnComboBox->addItem(this->tr('Date'));
    my $filterColumnLabel = Qt4::Label(this->tr('Filter &column:'));
    $filterColumnLabel->setBuddy($filterColumnComboBox);

    this->connect($filterPatternLineEdit, SIGNAL 'textChanged(const QString &)',
            this, SLOT 'filterRegExpChanged()');
    this->connect($filterSyntaxComboBox, SIGNAL 'currentIndexChanged(int)',
            this, SLOT 'filterRegExpChanged()');
    this->connect($filterColumnComboBox, SIGNAL 'currentIndexChanged(int)',
            this, SLOT 'filterColumnChanged()');
    this->connect($filterCaseSensitivityCheckBox, SIGNAL 'toggled(bool)',
            this, SLOT 'filterRegExpChanged()');
    this->connect($sortCaseSensitivityCheckBox, SIGNAL 'toggled(bool)',
            this, SLOT 'sortChanged()');

    my $sourceLayout = Qt4::HBoxLayout();
    $sourceLayout->addWidget($sourceView);
    $sourceGroupBox->setLayout($sourceLayout);

    my $proxyLayout = Qt4::GridLayout();
    $proxyLayout->addWidget($proxyView, 0, 0, 1, 3);
    $proxyLayout->addWidget($filterPatternLabel, 1, 0);
    $proxyLayout->addWidget($filterPatternLineEdit, 1, 1, 1, 2);
    $proxyLayout->addWidget($filterSyntaxLabel, 2, 0);
    $proxyLayout->addWidget($filterSyntaxComboBox, 2, 1, 1, 2);
    $proxyLayout->addWidget($filterColumnLabel, 3, 0);
    $proxyLayout->addWidget($filterColumnComboBox, 3, 1, 1, 2);
    $proxyLayout->addWidget($filterCaseSensitivityCheckBox, 4, 0, 1, 2);
    $proxyLayout->addWidget($sortCaseSensitivityCheckBox, 4, 2);
    $proxyGroupBox->setLayout($proxyLayout);

    my $mainLayout = Qt4::VBoxLayout();
    $mainLayout->addWidget($sourceGroupBox);
    $mainLayout->addWidget($proxyGroupBox);
    this->setLayout($mainLayout);

    this->setWindowTitle(this->tr('Basic Sort/Filter Model'));
    this->resize(500, 450);

    $proxyView->sortByColumn(1, Qt4::AscendingOrder());
    $filterColumnComboBox->setCurrentIndex(1);

    $filterPatternLineEdit->setText('Andy|Grace');
    $filterCaseSensitivityCheckBox->setChecked(1);
    $sortCaseSensitivityCheckBox->setChecked(1);
}

sub setSourceModel {
    my ( $model ) = @_;
    my $proxyModel = this->{proxyModel};
    my $sourceView = this->{sourceView};
    $proxyModel->setSourceModel($model);
    $sourceView->setModel($model);
}

sub filterRegExpChanged {
    my $filterSyntaxComboBox = this->{filterSyntaxComboBox};
    my $filterCaseSensitivityCheckBox = this->{filterCaseSensitivityCheckBox};
    my $filterPatternLineEdit = this->{filterPatternLineEdit};
    my $proxyModel = this->{proxyModel};
    my $syntax =
            $filterSyntaxComboBox->itemData(
                    $filterSyntaxComboBox->currentIndex())->toInt();
    my $caseSensitivity =
            $filterCaseSensitivityCheckBox->isChecked() ? Qt4::CaseSensitive()
                                                       : Qt4::CaseInsensitive();

    my $regExp = Qt4::RegExp($filterPatternLineEdit->text(), $caseSensitivity, $syntax);
    $proxyModel->setFilterRegExp($regExp);
}

sub filterColumnChanged {
    my $proxyModel = this->{proxyModel};
    my $filterColumnComboBox = this->{filterColumnComboBox};
    $proxyModel->setFilterKeyColumn($filterColumnComboBox->currentIndex());
}

sub sortChanged {
    my $proxyModel = this->{proxyModel};
    my $sortCaseSensitivityCheckBox = this->{sortCaseSensitivityCheckBox};
    $proxyModel->setSortCaseSensitivity(
            $sortCaseSensitivityCheckBox->isChecked() ? Qt4::CaseSensitive()
                                                     : Qt4::CaseInsensitive() );
}

1;
