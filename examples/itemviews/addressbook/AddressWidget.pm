package AddressWidget;

use strict;
use warnings;
use blib;

use Qt;
use Qt::isa qw(Qt::TabWidget);
use TableModel;
use NewAddressTab;
use AddDialog;

use Qt::slots
    addEntry => [],
    addEntry2 => ['QString', 'QString'],
    editEntry => [],
    removeEntry => [];

use Qt::signals
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

    #if (!list.contains(pair)) {
        $table->insertRows(0, 1, Qt::ModelIndex());

        my $index = $table->index(0, 0, Qt::ModelIndex());
        $table->setData($index, $name, Qt::EditRole());
        $index = $table->index(0, 1, Qt::ModelIndex());
        $table->setData($index, $address, Qt::EditRole());
        this->removeTab(this->indexOf($newAddressTab));
    #} else {
        #Qt::MessageBox::information(this, tr("Duplicate Name"),
            #tr("The name \"%1\" already exists.").arg(name));
    #}
}

sub editEntry {
    my $temp = CAST this->currentWidget(), ' Qt::TableView';
    my $proxy = CAST $temp->model(), ' Qt::SortFilterProxyModel';
    my $selectionModel = $temp->selectionModel();
    my $table = this->{table};

    my $indexes = $selectionModel->selectedRows();
    my $i;        
    my $name;
    my $address;
    my $row;

    foreach my $index ( @{$indexes} ) {
        $row = $proxy->mapToSource($index)->row();
        $i = $table->index($row, 0, Qt::ModelIndex());
        my $varName = $table->data($i, Qt::DisplayRole());
        my $name = $varName->toString();
    
        $i = $table->index($row, 1, Qt::ModelIndex());
        my $varAddr = $table->data($i, Qt::DisplayRole());
        $address = $varAddr->toString();
    }

    my $aDialog = AddDialog();
    $aDialog->setWindowTitle(this->tr('Edit a Contact'));

    $aDialog->nameText->setReadOnly(1);
    $aDialog->nameText->setText($name);
    $aDialog->addressText->setText($address);

    if ($aDialog->exec()) {
        my $newAddress = $aDialog->addressText()->toPlainText();
        if ($newAddress != $address) {
            $i = $table->index($row, 1, Qt::ModelIndex());
            $table->setData($i, $newAddress, Qt::EditRole());
        }
    }
}

sub removeEntry {
    my $temp = CAST this->currentWidget(), ' Qt::TableView';
    my $proxy = CAST $temp->model(), ' Qt::SortFilterProxyModel';
    my $selectionModel = $temp->selectionModel();
    my $table = this->{table};

    my $indexes = $selectionModel->selectedRows();

    foreach my $index ( @{$indexes} ) {
        my $row = $proxy->mapToSource($index)->row();
        $table->removeRows($row, 1, Qt::ModelIndex());
    }

    if ($table->rowCount(Qt::ModelIndex()) == 0) {
        this->insertTab(0, this->{newAddressTab}, 'Address Book');
    }
}

sub setupTabs {
    my @groups = ('ABC', 'DEF', 'GHI', 'JKL', 'MNO', 'PQR', 'STU', 'VW', 'XYZ');

    my $table = this->{table};

    foreach my $str ( @groups ) {
        my $proxyModel = Qt::SortFilterProxyModel(this);
        $proxyModel->setSourceModel($table);
        $proxyModel->setDynamicSortFilter(1);
    
        my $tableView = Qt::TableView();
        $tableView->setModel($proxyModel);
        $tableView->setSortingEnabled(1);
        $tableView->setSelectionBehavior(Qt::AbstractItemView::SelectRows());
        $tableView->horizontalHeader()->setStretchLastSection(1);
        $tableView->verticalHeader()->hide();
        $tableView->setEditTriggers(Qt::AbstractItemView::NoEditTriggers());
        $tableView->setSelectionMode(Qt::AbstractItemView::SingleSelection());

        my $newStr = "^[$str].*";

        $proxyModel->setFilterRegExp(Qt::RegExp($newStr, Qt::CaseInsensitive()));
        $proxyModel->setFilterKeyColumn(0);
        $proxyModel->sort(0, Qt::AscendingOrder());
    
        this->connect($tableView->selectionModel(),
            SIGNAL 'selectionChanged(QItemSelection,QItemSelection)',
            this, SIGNAL 'selectionChanged(QItemSelection)');

        this->addTab($tableView, $str);
    }
}

=begin

void AddressWidget::readFromFile(QString fileName)
{
    QFile file(fileName);

    if (!file.open(QIODevice::ReadOnly)) {
        QMessageBox::information(this, tr("Unable to open file"),
            file.errorString());
        return;
    }

    QList< QPair<QString, QString> > pairs = table->getList();    
    QDataStream in(&file);
    in >> pairs;

    if (pairs.isEmpty()) {
        QMessageBox::information(this, tr("No contacts in file"),
            tr("The file you are attempting to open contains no contacts."));  
    } else {
        for (int i=0; i<pairs.size(); ++i) {
            QPair<QString, QString> p = pairs.at(i);
            addEntry(p.first, p.second);
        }
    }
}

void AddressWidget::writeToFile(QString fileName)
{
    QFile file(fileName);

    if (!file.open(QIODevice::WriteOnly)) {
        QMessageBox::information(this, tr("Unable to open file"), file.errorString());
        return;
    }

    QList< QPair<QString, QString> > pairs = table->getList();    
    QDataStream out(&file);
    out << pairs;
}

=cut

1;
