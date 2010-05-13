package Window;

use strict;
use warnings;
use Qt4;
# [0]
use Qt4::isa qw( Qt4::Widget );
use Qt4::slots
    textFilterChanged => [],
    dateFilterChanged => [];

use MySortFilterProxyModel;

sub proxyModel() {
    return this->{proxyModel};
}

sub sourceGroupBox() {
    return this->{sourceGroupBox};
}

sub proxyGroupBox() {
    return this->{proxyGroupBox};
}

sub sourceView() {
    return this->{sourceView};
}

sub proxyView() {
    return this->{proxyView};
}

sub filterCaseSensitivityCheckBox() {
    return this->{filterCaseSensitivityCheckBox};
}

sub filterPatternLabel() {
    return this->{filterPatternLabel};
}

sub fromLabel() {
    return this->{fromLabel};
}

sub toLabel() {
    return this->{toLabel};
}

sub filterPatternLineEdit() {
    return this->{filterPatternLineEdit};
}

sub filterSyntaxComboBox() {
    return this->{filterSyntaxComboBox};
}

sub fromDateEdit() {
    return this->{fromDateEdit};
}

sub toDateEdit() {
    return this->{toDateEdit};
}
# [0]

# [0]
sub NEW
{
    my ($class) = @_;
    $class->SUPER::NEW();
    this->{proxyModel} = MySortFilterProxyModel(this);
    this->proxyModel->setDynamicSortFilter(1);
# [0]

# [1]
    this->{sourceView} = Qt4::TreeView();
    this->sourceView->setRootIsDecorated(0);
    this->sourceView->setAlternatingRowColors(1);
# [1]

    my $sourceLayout = Qt4::HBoxLayout();
# [2]
    $sourceLayout->addWidget(this->sourceView);
    this->{sourceGroupBox} = Qt4::GroupBox(this->tr('Original Model'));
    this->sourceGroupBox->setLayout($sourceLayout);
# [2]

# [3]
    this->{filterCaseSensitivityCheckBox} = Qt4::CheckBox(this->tr('Case sensitive filter'));
    this->filterCaseSensitivityCheckBox->setChecked(1);

    this->{filterPatternLineEdit} = Qt4::LineEdit();
    this->filterPatternLineEdit->setText('Grace|Sports');

    this->{filterPatternLabel} = Qt4::Label(this->tr('&Filter pattern:'));
    this->filterPatternLabel->setBuddy(this->filterPatternLineEdit);

    this->{filterSyntaxComboBox} = Qt4::ComboBox();
    this->filterSyntaxComboBox->addItem(this->tr('Regular expression'), Qt4::Variant(${Qt4::RegExp::RegExp()}));
    this->filterSyntaxComboBox->addItem(this->tr('Wildcard'), Qt4::Variant(${Qt4::RegExp::Wildcard()}));
    this->filterSyntaxComboBox->addItem(this->tr('Fixed string'), Qt4::Variant(${Qt4::RegExp::FixedString()}));

    this->{fromDateEdit} = Qt4::DateEdit();
    this->fromDateEdit->setDate(Qt4::Date(1970, 01, 01));
    this->{fromLabel} = Qt4::Label(this->tr('F&rom:'));
    this->fromLabel->setBuddy(this->fromDateEdit);

    this->{toDateEdit} = Qt4::DateEdit();
    this->toDateEdit->setDate(Qt4::Date(2099, 12, 31));
    this->{toLabel} = Qt4::Label(this->tr('&To:'));
    this->toLabel->setBuddy(this->toDateEdit);

    this->connect(this->filterPatternLineEdit, SIGNAL 'textChanged(const QString &)',
            this, SLOT 'textFilterChanged()');
    this->connect(this->filterSyntaxComboBox, SIGNAL 'currentIndexChanged(int)',
            this, SLOT 'textFilterChanged()');
    this->connect(this->filterCaseSensitivityCheckBox, SIGNAL 'toggled(bool)',
            this, SLOT 'textFilterChanged()');
    this->connect(this->fromDateEdit, SIGNAL 'dateChanged(const QDate &)',
            this, SLOT 'dateFilterChanged()');
    this->connect(this->toDateEdit, SIGNAL 'dateChanged(const QDate &)',
# [3] //! [4]
            this, SLOT 'dateFilterChanged()');
# [4]

# [5]
    this->{proxyView} = Qt4::TreeView();
    this->proxyView->setRootIsDecorated(0);
    this->proxyView->setAlternatingRowColors(1);
    this->proxyView->setModel(this->proxyModel);
    this->proxyView->setSortingEnabled(1);
    proxyView->sortByColumn(1, Qt4::AscendingOrder());

    my $proxyLayout = Qt4::GridLayout();
    $proxyLayout->addWidget(this->proxyView, 0, 0, 1, 3);
    $proxyLayout->addWidget(this->filterPatternLabel, 1, 0);
    $proxyLayout->addWidget(this->filterPatternLineEdit, 1, 1);
    $proxyLayout->addWidget(this->filterSyntaxComboBox, 1, 2);
    $proxyLayout->addWidget(this->filterCaseSensitivityCheckBox, 2, 0, 1, 3);
    $proxyLayout->addWidget(this->fromLabel, 3, 0);
    $proxyLayout->addWidget(this->fromDateEdit, 3, 1, 1, 2);
    $proxyLayout->addWidget(this->toLabel, 4, 0);
    $proxyLayout->addWidget(this->toDateEdit, 4, 1, 1, 2);

    this->{proxyGroupBox} = Qt4::GroupBox(this->tr('Sorted/Filtered Model'));
    this->proxyGroupBox->setLayout($proxyLayout);
# [5]

# [6]
    my $mainLayout = Qt4::VBoxLayout();
    $mainLayout->addWidget(this->sourceGroupBox);
    $mainLayout->addWidget(this->proxyGroupBox);
    this->setLayout($mainLayout);

    emit this->dateFilterChanged();
    emit this->textFilterChanged();

    this->setWindowTitle(this->tr('Custom Sort/Filter Model'));
    this->resize(500, 450);
}
# [6]

# [7]
sub setSourceModel
{
    my ($model) = @_;
    this->proxyModel->setSourceModel($model);
    this->sourceView->setModel($model);
}
# [7]

# [8]
sub textFilterChanged
{
    my $syntax = this->filterSyntaxComboBox->itemData(this->filterSyntaxComboBox->currentIndex())->toInt();
    my $caseSensitivity = this->filterCaseSensitivityCheckBox->isChecked() ?  1 : 0;

    my $pattern = this->filterPatternLineEdit->text();
    my $regExp;
    if ( $caseSensitivity ) {
        $regExp = qr/$pattern/;
    }
    else {
        $regExp = qr/$pattern/i;
    }

    proxyModel->setFilterRegExp($regExp);
}
# [8]

# [9]
sub dateFilterChanged
{
    this->proxyModel->setFilterMinimumDate(this->fromDateEdit->date());
    this->proxyModel->setFilterMaximumDate(this->toDateEdit->date());
}
# [9]

1;
