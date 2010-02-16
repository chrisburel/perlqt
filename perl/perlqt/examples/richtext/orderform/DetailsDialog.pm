package DetailsDialog;

use strict;
use warnings;
use Qt4;
# [0]
use Qt4::isa qw( Qt4::Dialog );
use Qt4::slots
    verify => [];
use List::Util qw(max);

sub nameLabel() {
    return this->{nameLabel};
}

sub addressLabel() {
    return this->{addressLabel};
}

sub offersCheckBox() {
    return this->{offersCheckBox};
}

sub nameEdit() {
    return this->{nameEdit};
}

sub items() {
    return this->{items};
}

sub itemsTable() {
    return this->{itemsTable};
}

sub addressEdit() {
    return this->{addressEdit};
}

sub buttonBox() {
    return this->{buttonBox};
}

# [0]
sub NEW
{
    my ($class, $title, $parent) = @_;
    $class->SUPER::NEW($parent);
    this->{nameLabel} = Qt4::Label(this->tr('Name:'));
    this->{addressLabel} = Qt4::Label(this->tr('Address:'));
    this->addressLabel->setAlignment(Qt4::AlignLeft() | Qt4::AlignTop());

    this->{nameEdit} = Qt4::LineEdit();
    this->{addressEdit} = Qt4::TextEdit();

    this->{offersCheckBox} = Qt4::CheckBox(this->tr('Send information about products and ' .
                                      'special offers'));

    this->setupItemsTable();

    this->{buttonBox} = Qt4::DialogButtonBox(Qt4::DialogButtonBox::Ok()
                                     | Qt4::DialogButtonBox::Cancel());

    this->connect(this->buttonBox, SIGNAL 'accepted()', this, SLOT 'verify()');
    this->connect(this->buttonBox, SIGNAL 'rejected()', this, SLOT 'reject()');
# [0]

# [1]
    my $mainLayout = Qt4::GridLayout();
    $mainLayout->addWidget(this->nameLabel, 0, 0);
    $mainLayout->addWidget(this->nameEdit, 0, 1);
    $mainLayout->addWidget(this->addressLabel, 1, 0);
    $mainLayout->addWidget(this->addressEdit, 1, 1);
    $mainLayout->addWidget(this->itemsTable, 0, 2, 2, 1);
    $mainLayout->addWidget(this->offersCheckBox, 2, 1, 1, 2);
    $mainLayout->addWidget(this->buttonBox, 3, 0, 1, 3);
    this->setLayout($mainLayout);

    this->setWindowTitle($title);
}
# [1]

# [2]
sub setupItemsTable
{
    this->{items} = [
        this->tr('T-shirt'), this->tr('Badge'), this->tr('Reference book'),
        this->tr('Coffee cup')
    ];

    this->{itemsTable} = Qt4::TableWidget(scalar @{this->items}, 2);

    for (my $row = 0; $row < scalar @{this->items}; ++$row) {
        my $name = Qt4::TableWidgetItem(this->items->[$row]);
        $name->setFlags(Qt4::ItemIsEnabled() | Qt4::ItemIsSelectable());
        this->itemsTable->setItem($row, 0, $name);
        my $quantity = Qt4::TableWidgetItem('1');
        this->itemsTable->setItem($row, 1, $quantity);
    }
}
# [2]

# [3]
sub orderItems
{
    my @orderList;

    for (my $row = 0; $row < scalar @{this->items}; ++$row) {
        my @item;
        $item[0] = this->itemsTable->item($row, 0)->text();
        my $quantity = this->itemsTable->item($row, 1)->data(Qt4::DisplayRole())->toInt();
        $item[1] = max(0, $quantity);
        push @orderList, [@item];
    }

    return \@orderList;
}
# [3]

# [4]
sub senderName
{
    return this->nameEdit->text();
}
# [4]

# [5]
sub senderAddress
{
    return this->addressEdit->toPlainText();
}
# [5]

# [6]
sub sendOffers
{
    return this->offersCheckBox->isChecked();
}
# [6]

# [7]
sub verify
{
    if (this->nameEdit->text() && this->addressEdit->toPlainText()) {
        this->accept();
        return;
    }

    my $answer = Qt4::MessageBox::warning(this, this->tr('Incomplete Form'),
        this->tr("The form does not contain all the necessary information.\n" .
           "Do you want to discard it?"),
        Qt4::MessageBox::Yes() | Qt4::MessageBox::No());

    if ($answer == Qt4::MessageBox::Yes()) {
        this->reject();
    }
}
# [7]

1;
