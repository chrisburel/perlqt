package MainWindow;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::MainWindow );
use Qt4::slots
    about => [],
    addAlbum => [],
    changeArtist => ['int'],
    deleteAlbum => [],
    showAlbumDetails => ['QModelIndex'],
    showArtistProfile => ['QModelIndex'],
    updateHeader => ['QModelIndex', 'int', 'int'];

use Dialog;

sub NEW
{
    my ($class, $artistTable, $albumTable, $albumDetails, $parent) = @_;
    $class->SUPER::NEW($parent);
    this->{file} = $albumDetails;
    this->{albumData} = Qt4::DomDocument();
    this->readAlbumData();

    this->{model} = Qt4::SqlRelationalTableModel(this);
    this->{model}->setTable($albumTable);
    this->{model}->setRelation(2, Qt4::SqlRelation($artistTable, 'id', 'artist'));
    this->{model}->select();

    my $artists = this->createArtistGroupBox();
    my $albums = this->createAlbumGroupBox();
    my $details = this->createDetailsGroupBox();

    this->{artistView}->setCurrentIndex(0);
    $Dialog::uniqueAlbumId = this->{model}->rowCount();
    $Dialog::uniqueArtistId = this->{artistView}->count();

    this->connect(this->{model}, SIGNAL 'rowsInserted(QModelIndex, int, int)',
            this, SLOT 'updateHeader(QModelIndex, int, int)');
    this->connect(this->{model}, SIGNAL 'rowsRemoved(QModelIndex, int, int)',
            this, SLOT 'updateHeader(QModelIndex, int, int)');

    my $layout = Qt4::GridLayout();
    $layout->addWidget($artists, 0, 0);
    $layout->addWidget($albums, 1, 0);
    $layout->addWidget($details, 0, 1, 2, 1);
    $layout->setColumnStretch(1, 1);
    $layout->setColumnMinimumWidth(0, 500);

    my $widget = Qt4::Widget();
    $widget->setLayout($layout);
    this->setCentralWidget($widget);
    this->createMenuBar();

    this->showImageLabel();
    this->resize(850, 400);
    this->setWindowTitle(this->tr('Music Archive'));
}

sub changeArtist
{
    my ($row) = @_;
    if ($row > 0) {
        my $index = this->{model}->relationModel(2)->index($row, 1);
        this->{model}->setFilter('artist = \'' . $index->data()->toString() . '\'') ;
        this->showArtistProfile($index);
    } elsif ($row == 0) {
        this->{model}->setFilter('');
        this->showImageLabel();
    } else {
        return;
    }
}

sub showArtistProfile
{
    my ($index) = @_;
    my $record = this->{model}->relationModel(2)->record($index->row());

    my $name = $record->value('artist')->toString();
    my $count = $record->value('albumcount')->toString();
    this->{profileLabel}->setText(sprintf this->tr("Artist : %s \n" .
                             'Number of Albums: %s'), $name, $count);

    this->{profileLabel}->show();
    this->{iconLabel}->show();

    this->{titleLabel}->hide();
    this->{trackList}->hide();
    this->{imageLabel}->hide();
}

sub showAlbumDetails
{
    my ($index) = @_;
    my $record = this->{model}->record($index->row());

    my $artist = $record->value('artist')->toString();
    my $title = $record->value('title')->toString();
    my $year = $record->value('year')->toString();
    my $albumId = $record->value('albumid')->toString();

    this->showArtistProfile(this->indexOfArtist($artist));
    this->{titleLabel}->setText(sprintf this->tr('Title: %s (%s)'), $title, $year);
    this->{titleLabel}->show();

    my $albums = this->{albumData}->elementsByTagName('album');
    foreach my $i (0..$albums->count()-1) {
        my $album = $albums->item($i);
        if ($album->toElement()->attribute('id') == $albumId) {
            this->getTrackList($album->toElement());
            last;
        }
    }
    if (!this->{trackList}->count() == 0) {
        this->{trackList}->show();
    }
}

sub getTrackList
{
    my ($album) = @_;
    this->{trackList}->clear();

    my $tracks = $album->childNodes();
    my $track;
    my $trackNumber;

    foreach my $j (0..$tracks->count()-1) {

        $track = $tracks->item($j);
        $trackNumber = $track->toElement()->attribute('number');

        my $item = Qt4::ListWidgetItem(this->{trackList});
        $item->setText($trackNumber . ': ' . $track->toElement()->text());
    }
}

sub addAlbum
{
    my $dialog = Dialog(this->{model}, this->{albumData}, this->{file}, this);
    my $accepted = $dialog->exec();

    if ($accepted == 1) {
        my $lastRow = this->{model}->rowCount() - 1;
        this->{albumView}->selectRow($lastRow);
        this->{albumView}->scrollToBottom();
        this->showAlbumDetails(this->{model}->index($lastRow, 0));
    }
}

sub deleteAlbum
{
    my $selection = this->{albumView}->selectionModel()->selectedRows(0);

    if ($selection && ref $selection eq 'ARRAY') {
        my $idIndex = $selection->at(0);
        my $id = $idIndex->data()->toInt();
        my $title = $idIndex->sibling($idIndex->row(), 1)->data()->toString();
        my $artist = $idIndex->sibling($idIndex->row(), 2)->data()->toString();

        my $button = Qt4::MessageBox::question(this, this->tr('Delete Album'),
                                       sprintf(this->tr('Are you sure you want to ' .
                                                  'delete \'%s\' by \'%s\'?'),
                                              $title, $artist),
                                       Qt4::MessageBox::Yes() | Qt4::MessageBox::No());

        if ($button == Qt4::MessageBox::Yes()) {
            this->removeAlbumFromFile($id);
            this->removeAlbumFromDatabase($idIndex);
            this->decreaseAlbumCount(this->indexOfArtist($artist));

            this->showImageLabel();
        }
    } else {
        Qt4::MessageBox::information(this, this->tr('Delete Album'),
                                 this->tr('Select the album you want to delete.'));
    }
}

sub removeAlbumFromFile
{
    my ($id) = @_;

    my $albums = this->{albumData}->elementsByTagName('album');

    foreach my $i (0..$#{$albums}) {
        my $node = $albums->[$i];
        if ($node->toElement()->attribute('id')->toInt() == $id) {
            this->{albumData}->elementsByTagName('archive')->item(0)->removeChild($node);
            last;
        }
    }

    #The following code is commented out since the example uses an in
    #memory database, i.e., altering the XML this->{file} will bring the data
    #out of sync.

    #if (!this->{file}->open(Qt4::IODevice::WriteOnly)) {
        #return;
    #} else {
        #Qt4::TextStream stream(this->{file});
        #this->{albumData}.elementsByTagName('archive').item(0).save(stream, 4);
        #this->{file}->close();
    #}
}

sub removeAlbumFromDatabase
{
    my ($index) = @_;
    this->{model}->removeRow($index->row());
}

sub decreaseAlbumCount
{
    my ($artistIndex) = @_;
    my $row = $artistIndex->row();
    my $albumCountIndex = $artistIndex->sibling($row, 2);
    my $albumCount = $albumCountIndex->data()->toInt();

    my $artists = this->{model}->relationModel(2);

    if ($albumCount == 1) {
        splice @{$artists}, $row, 1;
        this->showImageLabel();
    } else {
        artists->setData($albumCountIndex, Qt4::Variant($albumCount - 1));
    }
}

sub readAlbumData
{
    if (!this->{file}->open(Qt4::IODevice::ReadOnly())) {
        return;
    }

    if (!this->{albumData}->setContent(this->{file})) {
        this->{file}->close();
        return;
    }
    this->{file}->close();
}

sub createArtistGroupBox
{
    this->{artistView} = Qt4::ComboBox();
    this->{artistView}->setModel(this->{model}->relationModel(2));
    this->{artistView}->setModelColumn(1);

    this->connect(this->{artistView}, SIGNAL 'currentIndexChanged(int)',
            this, SLOT 'changeArtist(int)');

    my $box = Qt4::GroupBox(this->tr('Artist'));

    my $layout = Qt4::GridLayout();
    $layout->addWidget(this->{artistView}, 0, 0);
    $box->setLayout($layout);

    return $box;
}

sub createAlbumGroupBox
{
    my $box = Qt4::GroupBox(this->tr('Album'));

    this->{albumView} = Qt4::TableView();
    this->{albumView}->setEditTriggers(Qt4::AbstractItemView::NoEditTriggers());
    this->{albumView}->setSortingEnabled(1);
    this->{albumView}->setSelectionBehavior(Qt4::AbstractItemView::SelectRows());
    this->{albumView}->setSelectionMode(Qt4::AbstractItemView::SingleSelection());
    this->{albumView}->setShowGrid(0);
    this->{albumView}->verticalHeader()->hide();
    this->{albumView}->setAlternatingRowColors(1);
    this->{albumView}->setModel(this->{model});
    this->adjustHeader();

    my $locale = this->{albumView}->locale();
    $locale->setNumberOptions(Qt4::Locale::OmitGroupSeparator());
    this->{albumView}->setLocale($locale);

    this->connect(this->{albumView}, SIGNAL 'clicked(QModelIndex)',
            this, SLOT 'showAlbumDetails(QModelIndex)');
    this->connect(this->{albumView}, SIGNAL 'activated(QModelIndex)',
            this, SLOT 'showAlbumDetails(QModelIndex)');

    my $layout = Qt4::VBoxLayout();
    $layout->addWidget(this->{albumView}, 0, 0);
    $box->setLayout($layout);

    return $box;
}

sub createDetailsGroupBox
{
    my $box = Qt4::GroupBox(this->tr('Details'));

    this->{profileLabel} = Qt4::Label();
    this->{profileLabel}->setWordWrap(1);
    this->{profileLabel}->setAlignment(Qt4::AlignBottom());

    this->{titleLabel} = Qt4::Label();
    this->{titleLabel}->setWordWrap(1);
    this->{titleLabel}->setAlignment(Qt4::AlignBottom());

    this->{iconLabel} = Qt4::Label();
    this->{iconLabel}->setAlignment(Qt4::AlignBottom() | Qt4::AlignRight());
    this->{iconLabel}->setPixmap(Qt4::Pixmap('images/icon.png'));

    this->{imageLabel} = Qt4::Label();
    this->{imageLabel}->setWordWrap(1);
    this->{imageLabel}->setAlignment(Qt4::AlignCenter());
    this->{imageLabel}->setPixmap(Qt4::Pixmap('images/image.png'));

    this->{trackList} = Qt4::ListWidget();

    my $layout = Qt4::GridLayout();
    $layout->addWidget(this->{imageLabel}, 0, 0, 3, 2);
    $layout->addWidget(this->{profileLabel}, 0, 0);
    $layout->addWidget(this->{iconLabel}, 0, 1);
    $layout->addWidget(this->{titleLabel}, 1, 0, 1, 2);
    $layout->addWidget(this->{trackList}, 2, 0, 1, 2);
    $layout->setRowStretch(2, 1);
    $box->setLayout($layout);

    return $box;
}

sub createMenuBar
{
    my $addAction = Qt4::Action(this->tr('&Add album...'), this);
    my $deleteAction = Qt4::Action(this->tr('&Delete album...'), this);
    my $quitAction = Qt4::Action(this->tr('&Quit'), this);
    my $aboutAction = Qt4::Action(this->tr('&About'), this);
    my $aboutQtAction = Qt4::Action(this->tr('About &Qt'), this);

    $addAction->setShortcut(Qt4::KeySequence(this->tr('Ctrl+A')));
    $deleteAction->setShortcut(Qt4::KeySequence(this->tr('Ctrl+D')));
    $quitAction->setShortcut(Qt4::KeySequence(this->tr('Ctrl+Q')));

    my $fileMenu = this->menuBar()->addMenu(this->tr('&File'));
    $fileMenu->addAction($addAction);
    $fileMenu->addAction($deleteAction);
    $fileMenu->addSeparator();
    $fileMenu->addAction($quitAction);

    my $helpMenu = this->menuBar()->addMenu(this->tr('&Help'));
    $helpMenu->addAction($aboutAction);
    $helpMenu->addAction($aboutQtAction);

    this->connect($addAction, SIGNAL 'triggered(bool)', this, SLOT 'addAlbum()');
    this->connect($deleteAction, SIGNAL 'triggered(bool)', this, SLOT 'deleteAlbum()');
    this->connect($quitAction, SIGNAL 'triggered(bool)', this, SLOT 'close()');
    this->connect($aboutAction, SIGNAL 'triggered(bool)', this, SLOT 'about()');
    this->connect($aboutQtAction, SIGNAL 'triggered(bool)', qApp, SLOT 'aboutQt()');
}

sub showImageLabel
{
    this->{profileLabel}->hide();
    this->{titleLabel}->hide();
    this->{iconLabel}->hide();
    this->{trackList}->hide();

    this->{imageLabel}->show();
}

sub indexOfArtist
{
    my ($artist) = @_;
    my $artistModel = this->{model}->relationModel(2);

    foreach my $i (0..$artistModel->rowCount()-1) {
        my $record = $artistModel->record($i);
        if ($record->value('artist') eq $artist) {
            return $artistModel->index($i, 1);
        }
    }
    return Qt4::ModelIndex();
}

sub updateHeader
{
    this->adjustHeader();
}

sub adjustHeader
{
    this->{albumView}->hideColumn(0);
    this->{albumView}->horizontalHeader()->setResizeMode(1, Qt4::HeaderView::Stretch());
    this->{albumView}->resizeColumnToContents(2);
    this->{albumView}->resizeColumnToContents(3);
}

sub about
{
    Qt4::MessageBox::about(this, this->tr('About Music Archive'),
            this->tr('<p>The <b>Music Archive</b> example shows how to present ' .
               'data from different data sources in the same application. ' .
               'The album titles, and the corresponding artists and release dates, ' .
               'are kept in a database, while each album\'s tracks are stored ' .
               'in an XML this->{file}. </p><p>The example also shows how to add as ' .
               'well as remove data from both the database and the ' .
               'associated XML this->{file} using the API provided by the QtSql and ' .
               'QtXml modules, respectively.</p>'));
}

1;
