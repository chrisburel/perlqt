package MainWindow;

use strict;
use warnings;
use blib;

use Qt;
use Qt::isa qw( Qt::MainWindow );
use AddressWidget;

use Qt::slots
    updateActions => ['QItemSelection'],
    openFile      => [],
    saveFile      => [];

sub NEW {
    shift->SUPER::NEW(@_);
    my $addressWidget = AddressWidget( undef );
    this->{addressWidget} = $addressWidget;
    this->setCentralWidget($addressWidget);
    createMenus();
    this->setWindowTitle(this->tr('Address Book'));
}

sub createMenus {
    my $addressWidget = this->{addressWidget};
    my $fileMenu = this->menuBar()->addMenu(this->tr("&File"));
    
    my $openAct = Qt::Action(this->tr("&Open..."), this);
    $fileMenu->addAction($openAct);
    this->connect($openAct, SIGNAL 'triggered()',
        this, SLOT 'openFile()');

    my $saveAct = Qt::Action(this->tr("&Save As..."), this);
    $fileMenu->addAction($saveAct);
    this->connect($saveAct, SIGNAL 'triggered()',
        this, SLOT 'saveFile()');

    $fileMenu->addSeparator();

    my $exitAct = Qt::Action(this->tr("E&xit"), this);
    $fileMenu->addAction($exitAct);
    this->connect($exitAct, SIGNAL 'triggered()',
        this, SLOT 'close()');

    my $toolMenu = this->menuBar()->addMenu(this->tr("&Tools"));

    my $addAct = Qt::Action(this->tr("&Add Entry..."), this);
    $toolMenu->addAction($addAct);
    this->connect($addAct, SIGNAL 'triggered()',
        $addressWidget, SLOT 'addEntry()');
    

    my $editAct = Qt::Action(this->tr("&Edit Entry..."), this);
    $editAct->setEnabled(0);
    $toolMenu->addAction($editAct);
    this->connect($editAct, SIGNAL 'triggered()',
        $addressWidget, SLOT 'editEntry()');

    $toolMenu->addSeparator();

    my $removeAct = Qt::Action(this->tr("&Remove Entry"), this);
    $removeAct->setEnabled(0);
    $toolMenu->addAction($removeAct);
    this->connect($removeAct, SIGNAL 'triggered()',
        $addressWidget, SLOT 'removeEntry()');

    this->connect($addressWidget, SIGNAL 'selectionChanged(QItemSelection)',
        this, SLOT 'updateActions(QItemSelection)');
}

=begin

sub openFile {
    Qt::String fileName = Qt::FileDialog::getOpenFileName(this);
    if (!fileName.isEmpty()) {
        addressWidget->readFromFile(fileName);
    }
}



sub saveFile {
    Qt::String fileName = Qt::FileDialog::getSaveFileName(this);
    if (!fileName.isEmpty()) {
        addressWidget->writeToFile(fileName);
    }
}



sub updateActions(const Qt::ItemSelection &selection) {
    Qt::ModelIndexList indexes = selection.indexes();
    
    if (!indexes.isEmpty()) {
        removeAct->setEnabled(this->true);
        editAct->setEnabled(this->true);
    } else {
        removeAct->setEnabled(false);
        editAct->setEnabled(false);
    }
}

=cut

1;
