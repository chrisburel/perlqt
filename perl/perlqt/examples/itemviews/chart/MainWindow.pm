package MainWindow;

use strict;
use warnings;
use blib;

use PieView;
use Qt4;
use Qt4::isa qw( Qt4::MainWindow );
use Qt4::slots
    openFile => ['const Qt4::String'],
    openFile => [],
    saveFile => [];

sub NEW {
    shift->SUPER::NEW();
    my $fileMenu = Qt4::Menu(this->tr('&File'), this);
    my $openAction = $fileMenu->addAction(this->tr('&Open...'));
    $openAction->setShortcut(Qt4::KeySequence(this->tr('Ctrl+O')));
    my $saveAction = $fileMenu->addAction(this->tr('&Save As...'));
    $saveAction->setShortcut(Qt4::KeySequence(this->tr('Ctrl+S')));
    my $quitAction = $fileMenu->addAction(this->tr('E&xit'));
    $quitAction->setShortcut(Qt4::KeySequence(this->tr('Ctrl+Q')));

    setupModel();
    setupViews();

    this->connect($openAction, SIGNAL 'triggered()', this, SLOT 'openFile()');
    this->connect($saveAction, SIGNAL 'triggered()', this, SLOT 'saveFile()');
    this->connect($quitAction, SIGNAL 'triggered()', Qt4::qApp, SLOT 'quit()');

    this->menuBar()->addMenu($fileMenu);
    this->statusBar();

    openFile('qtdata.cht');

    this->setWindowTitle(this->tr('Chart'));
    this->resize(870, 550);
}

sub setupModel {
    my $model = Qt4::StandardItemModel(8, 2, this);
    this->{model} = $model;
    $model->setHeaderData(0, Qt4::Horizontal(), Qt4::Variant(Qt4::String(this->tr('Label'))));
    $model->setHeaderData(1, Qt4::Horizontal(), Qt4::Variant(Qt4::String(this->tr('Quantity'))));
}

sub setupViews {
    my $splitter = Qt4::Splitter();
    my $table = Qt4::TableView();
    my $pieChart = PieView();
    my $model = this->{model};
    this->{pieChart} = $pieChart;
    $splitter->addWidget($table);
    $splitter->addWidget($pieChart);
    $splitter->setStretchFactor(0, 0);
    $splitter->setStretchFactor(1, 1);

    $table->setModel($model);
    $pieChart->setModel($model);

    my $selectionModel = Qt4::ItemSelectionModel($model);
    this->{selectionModel} = $selectionModel;
    $table->setSelectionModel($selectionModel);
    $pieChart->setSelectionModel($selectionModel);

    my $headerView = $table->horizontalHeader();
    $headerView->setStretchLastSection(1);

    this->setCentralWidget($splitter);
}

sub openFile {
    my ($path) = @_;
    my $fileName;
    my $model = this->{model};
    if (!$path) {
        $fileName = Qt4::FileDialog::getOpenFileName(this, this->tr('Choose a data file'),
                                                '', '*.cht');
    }
    else {
        $fileName = $path;
    }

    if ($fileName) {
        my $file = Qt4::File($fileName);

        if ($file->open(Qt4::File::ReadOnly() | Qt4::File::Text())) {
            my $stream = Qt4::TextStream($file);
            my $line;

            $model->removeRows(0, $model->rowCount(Qt4::ModelIndex()), Qt4::ModelIndex());

            my $row = 0;
            do {
                $line = $stream->readLine();
                if ($line) {

                    $model->insertRows($row, 1, Qt4::ModelIndex());

                    my @pieces = grep { $_ } split /,/, $line;
                    $model->setData($model->index($row, 0, Qt4::ModelIndex()),
                                   Qt4::Variant(Qt4::String($pieces[0])));
                    $model->setData($model->index($row, 1, Qt4::ModelIndex()),
                                   Qt4::Variant(Qt4::String($pieces[1])));
                    $model->setData($model->index($row, 0, Qt4::ModelIndex()),
                                   Qt4::qVariantFromValue(Qt4::Color(Qt4::String($pieces[2]))), Qt4::DecorationRole());
                    $row++;
                }
            } while ($line);

            $file->close();
            this->statusBar()->showMessage(this->tr("Loaded $fileName"), 2000);
        }
    }
}

sub saveFile {
    my $model = this->{model};
    my $fileName = Qt4::FileDialog::getSaveFileName(this,
        this->tr('Save file as'), '', '*.cht');

    if ($fileName) {
        my $file = Qt4::File($fileName);
        my $stream = Qt4::TextStream($file);

        if ($file->open(Qt4::File::WriteOnly() | Qt4::File::Text())) {
            foreach my $row (0..$model->rowCount(Qt4::ModelIndex())-1) {

                my @pieces;

                push @pieces, $model->data($model->index($row, 0, Qt4::ModelIndex()),
                                          Qt4::DisplayRole())->toString();
                push @pieces, $model->data($model->index($row, 1, Qt4::ModelIndex()),
                                          Qt4::DisplayRole())->toString();
                push @pieces, $model->data($model->index($row, 0, Qt4::ModelIndex()),
                                          Qt4::DecorationRole())->toString();

                {
                    no warnings qw(void);
                    $stream << join ( ',', @pieces ) . "\n";
                }
            }
        }

        $file->close();
        this->statusBar()->showMessage(this->tr("Saved $fileName"), 2000);
    }
}

1;
