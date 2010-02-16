package AddressWidget;

use strict;
use warnings;
use blib;

use Devel::Peek;
use Qt4;
use Qt4::isa qw(Qt4::TabWidget);
use TableModel;
use NewAddressTab;
use AddDialog;

use List::Util qw(first);

use Qt4::slots
    addEntry => [],
    addEntry2 => ['QString', 'QString'],
    editEntry => [],
    removeEntry => [];

use Qt4::signals
    selectionChanged => ['QItemSelection'];

sub NEW {
    shift->SUPER::NEW(@_);

    my $table = TableModel(this);
    this->{table} = $table;
    my $newAddressTab = NewAddressTab(this);
    this->{newAddressTab} = $newAddressTab;
    this->connect($newAddressTab, SIGNAL 'sendDetails(QString, QString)',
        this, SLOT 'addEntry2(QString, QString)');

    this->addTab($newAddressTab, 'Address Book');

    setupTabs();

}

sub addEntry {
    my $aDialog = AddDialog();

    if ($aDialog->exec()) {
        my $name = $aDialog->nameText()->text();
        my $address = $aDialog->addressText()->toPlainText();

        this->addEntry2($name, $address);
    }
}

sub addEntry2 {
    my ($name, $address) = @_;
    my $table = this->{table};
    my $newAddressTab = this->{newAddressTab};
    my $list = $table->getList();

    if ( !first{ $_->[0] eq $name && $_->[1] eq $address } @{$list}) {
        $table->insertRows(0, 1, Qt4::ModelIndex());

        my $index = $table->index(0, 0, Qt4::ModelIndex());
        $table->setData($index, $name, Qt4::EditRole());
        $index = $table->index(0, 1, Qt4::ModelIndex());
        $table->setData($index, $address, Qt4::EditRole());
        this->removeTab(this->indexOf($newAddressTab));
    } else {
        #Qt4::MessageBox::information(this, this->tr('Duplicate Name'),
            #this->tr("The name \"$name\" already exists."));
    }
}

sub editEntry {
    my $temp = CAST this->currentWidget(), 'Qt4::TableView';
    my $proxy = CAST $temp->model(), 'Qt4::SortFilterProxyModel';
    my $selectionModel = $temp->selectionModel();
    my $table = this->{table};

    my $indexes = $selectionModel->selectedRows();
    my $i;
    my $name;
    my $address;
    my $row;

    foreach my $index ( @{$indexes} ) {
        $row = $proxy->mapToSource($index)->row();
        $i = $table->index($row, 0, Qt4::ModelIndex());
        my $varName = $table->data($i, Qt4::DisplayRole());
        $name = $varName->toString();

        $i = $table->index($row, 1, Qt4::ModelIndex());
        my $varAddr = $table->data($i, Qt4::DisplayRole());
        $address = $varAddr->toString();
    }

    my $aDialog = AddDialog();
    $aDialog->setWindowTitle(this->tr('Edit a Contact'));

    $aDialog->nameText->setReadOnly(1);
    $aDialog->nameText->setText($name);
    $aDialog->addressText->setText($address);

    if ($aDialog->exec()) {
        my $newAddress = $aDialog->addressText()->toPlainText();
        if ($newAddress ne $address) {
            $i = $table->index($row, 1, Qt4::ModelIndex());
            $table->setData($i, $newAddress, Qt4::EditRole());
        }
    }
}

sub removeEntry {
    my $temp = CAST this->currentWidget(), 'Qt4::TableView';
    my $proxy = CAST $temp->model(), 'Qt4::SortFilterProxyModel';
    my $selectionModel = $temp->selectionModel();
    my $table = this->{table};

    my $indexes = $selectionModel->selectedRows();

    foreach my $index ( @{$indexes} ) {
        my $row = $proxy->mapToSource($index)->row();
        $table->removeRows($row, 1, Qt4::ModelIndex());
    }

    if ($table->rowCount(Qt4::ModelIndex()) == 0) {
        this->insertTab(0, this->{newAddressTab}, 'Address Book');
    }
}

sub setupTabs {
    my @groups = ('ABC', 'DEF', 'GHI', 'JKL', 'MNO', 'PQR', 'STU', 'VW', 'XYZ');

    my $table = this->{table};

    foreach my $str ( @groups ) {
        my $proxyModel = Qt4::SortFilterProxyModel(this);
        $proxyModel->setSourceModel($table);
        $proxyModel->setDynamicSortFilter(1);

        my $tableView = Qt4::TableView();
        $tableView->setModel($proxyModel);
        $tableView->setSortingEnabled(1);
        $tableView->setSelectionBehavior(Qt4::AbstractItemView::SelectRows());
        $tableView->horizontalHeader()->setStretchLastSection(1);
        $tableView->verticalHeader()->hide();
        $tableView->setEditTriggers(Qt4::AbstractItemView::NoEditTriggers());
        $tableView->setSelectionMode(Qt4::AbstractItemView::SingleSelection());

        my $newStr = "^[$str].*";

        $proxyModel->setFilterRegExp(Qt4::RegExp($newStr, Qt4::CaseInsensitive()));
        $proxyModel->setFilterKeyColumn(0);
        $proxyModel->sort(0, Qt4::AscendingOrder());

        this->connect($tableView->selectionModel(),
            SIGNAL 'selectionChanged(QItemSelection,QItemSelection)',
            this, SIGNAL 'selectionChanged(QItemSelection)');

        this->addTab($tableView, $str);
    }
}

sub readFromFile {
    my ($fileName) = @_;

    my $file = Qt4::File( $fileName );
    if(!$file->open(Qt4::IODevice::ReadOnly())) {
        Qt4::MessageBox::information(this, this->tr('Unable to open file'),
            $file->errorString());
        return;
    }

    my $pairs = [];
    my $in = Qt4::DataStream($file);
    while( !$file->atEnd() ) {
        my $pair = [];
        {
            no warnings; # For bitshift warning
            $in >> $pair;
        }
        push @{$pairs}, $pair;
    }
    $file->close();

    if (!@{$pairs}) {
        Qt4::MessageBox::information(this, this->tr('No contacts in file'),
            this->tr('The file you are attempting to open contains no contacts.'));
    }
    else {
        foreach my $pair ( @{$pairs} ) {
            addEntry2($pair->[0], $pair->[1]);
        }
    }
}

sub writeToFile {
    my ($fileName) = @_;

    my $file = Qt4::File($fileName);
    if(!$file->open(Qt4::IODevice::WriteOnly())) {
        Qt4::MessageBox::information(this, this->tr('Unable to open file'),
            $file->errorString());
        return;
    }

    my $pairs = this->{table}->getList();
    my $out = Qt4::DataStream( $file );
    # The binding is going to interpret this as a QStringList
    foreach my $pair ( @{$pairs} ) {
        {
            no warnings; # For bitshift warning
            $out << $pair;
        }
    }
    $file->close();
}

1;
