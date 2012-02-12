package MainWindow;

use QtCore4;
use QtCore4::debug qw(ambiguous);
use Phonon;

use QtCore4::isa qw( Qt::MainWindow );
use QtCore4::slots
    addFiles => [],
    about => [],
    stateChanged => ['Phonon::State', 'Phonon::State'],
    tick => ['qint64'],
    sourceChanged => ['const Phonon::MediaSource &'],
    metaStateChanged => ['Phonon::State', 'Phonon::State'],
    aboutToFinish => [],
    tableClicked => ['int', 'int'];

sub NEW {
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
    this->{audioOutput} = Phonon::AudioOutput(Phonon::MusicCategory(), this);
    this->{mediaObject} = Phonon::MediaObject(this);
    this->{metaInformationResolver} = Phonon::MediaObject(this);

    this->{mediaObject}->setTickInterval(1000);
    this->connect(this->{mediaObject}, SIGNAL 'tick(qint64)', this, SLOT 'tick(qint64)');
    this->connect(this->{mediaObject}, SIGNAL 'stateChanged(Phonon::State,Phonon::State)',
            this, SLOT 'stateChanged(Phonon::State,Phonon::State)');
    this->connect(this->{metaInformationResolver}, SIGNAL 'stateChanged(Phonon::State,Phonon::State)',
            this, SLOT 'metaStateChanged(Phonon::State,Phonon::State)');
    this->connect(this->{mediaObject}, SIGNAL 'currentSourceChanged(Phonon::MediaSource)',
            this, SLOT 'sourceChanged(Phonon::MediaSource)');
    this->connect(this->{mediaObject}, SIGNAL 'aboutToFinish()', this, SLOT 'aboutToFinish()');

    Phonon::createPath(this->{mediaObject}, this->{audioOutput});

    this->setupActions();
    this->setupMenus();
    this->setupUi();
    this->{timeLcd}->display('00:00');
    this->{sources} = [];
}

sub indexOfSource
{
    my ($source) = @_;
    my $index = -1;
    foreach my $sourceIdx ( 0..$#{this->{sources}} ) {
        if ( $source == this->{sources}->[$sourceIdx] ) {
            $index = $sourceIdx;
            last;
        }
    }
    return $index;
}

sub sizeHint
{
    return Qt::Size(500, 300);
}


sub addFiles
{
    my $files = Qt::FileDialog::getOpenFileNames(this, this->tr('Select Music Files'),
        Qt::DesktopServices::storageLocation(Qt::DesktopServices::MusicLocation()));

    if (scalar @{$files} == 0) {
        return;
    }

    my $index = scalar @{this->{sources}};
    foreach my $string (@{$files}) {
        my $source = Phonon::MediaSource($string);

        push @{this->{sources}}, $source;
    }
    if (scalar @{this->{sources}} > 0) {
        this->{metaInformationResolver}->setCurrentSource(this->{sources}->[$index]);
    }

}

sub about
{
    Qt::MessageBox::information(this, this->tr('About Music Player'),
        this->tr('The Music Player example shows how to use Phonon - the multimedia' .
           ' framework that comes with Qt - to create a simple music player.'));
}

sub stateChanged
{
    my ($newState) = @_;
    if ($newState == Phonon::ErrorState()) {
        if (mediaObject->errorType() == Phonon::FatalError()) {
            Qt::MessageBox::warning(this, this->tr('Fatal Error'),
            this->{mediaObject}->errorString());
        } else {
            Qt::MessageBox::warning(this, this->tr('Error'),
            this->{mediaObject}->errorString());
        }
    }
    elsif ($newState == Phonon::PlayingState()) {
        this->{playAction}->setEnabled(0);
        this->{pauseAction}->setEnabled(1);
        this->{stopAction}->setEnabled(1);
    }
    elsif ($newState == Phonon::StoppedState()) {
        this->{stopAction}->setEnabled(0);
        this->{playAction}->setEnabled(1);
        this->{pauseAction}->setEnabled(0);
        this->{timeLcd}->display('00:00');
    }
    elsif ($newState == Phonon::PausedState()) {
        this->{pauseAction}->setEnabled(0);
        this->{stopAction}->setEnabled(1);
        this->{playAction}->setEnabled(1);
    }
    elsif ($newState == Phonon::BufferingState()) {
        # break;
    }
    else {
        ;
    }
}

sub tick
{
    my ($time) = @_;
    my $displayTime = Qt::Time(0, ($time / 60000) % 60, ($time / 1000) % 60);

    this->{timeLcd}->display($displayTime->toString('mm:ss'));
}

sub tableClicked
{
    my ($row) = @_;
    my $wasPlaying = this->{mediaObject}->state() == Phonon::PlayingState();

    this->{mediaObject}->stop();
    this->{mediaObject}->clearQueue();

    if ($row >= scalar @{this->{sources}}) {
        return;
    }

    this->{mediaObject}->setCurrentSource(this->{sources}->[$row]);

    if ($wasPlaying) {
        this->{mediaObject}->play();
    }
    else {
        this->{mediaObject}->stop();
    }
}

sub sourceChanged
{
    my ($source) = @_;
    my $index = indexOfSource($source);

    this->{musicTable}->selectRow($index);
    this->{timeLcd}->display('00:00');
}

sub metaStateChanged
{
    my ($newState) = @_;
    if ($newState == Phonon::ErrorState()) {
        Qt::MessageBox::warning(this, this->tr('Error opening files'),
            this->{metaInformationResolver}->errorString());
        while (@{this->{sources}} &&
               !(pop(@{this->{sources}}) == this->{metaInformationResolver}->currentSource())) {}  # loop */;
        return;
    }

    if ($newState != Phonon::StoppedState() && $newState != Phonon::PausedState()) {
        return;
    }

    if (this->{metaInformationResolver}->currentSource()->type() == Phonon::MediaSource::Invalid()) {
        return;
    }

    my $metaData = this->{metaInformationResolver}->metaData();

    my $title = $metaData->{TITLE}->[0];
    if ($title eq '') {
        $title = this->{metaInformationResolver}->currentSource()->fileName();
    }

    my $titleItem = Qt::TableWidgetItem(Qt::String($title));
    $titleItem->setFlags($titleItem->flags() ^ Qt::ItemIsEditable());
    my $artistItem = Qt::TableWidgetItem(Qt::String($metaData->{ARTIST}->[0]));
    $artistItem->setFlags($artistItem->flags() ^ Qt::ItemIsEditable());
    my $albumItem = Qt::TableWidgetItem(Qt::String($metaData->{ALBUM}->[0]));
    $albumItem->setFlags($albumItem->flags() ^ Qt::ItemIsEditable());
    my $yearItem = Qt::TableWidgetItem(Qt::String($metaData->{DATE}->[0]));
    $yearItem->setFlags($yearItem->flags() ^ Qt::ItemIsEditable());

    my $currentRow = this->{musicTable}->rowCount();
    this->{musicTable}->insertRow($currentRow);
    this->{musicTable}->setItem($currentRow, 0, $titleItem);
    this->{musicTable}->setItem($currentRow, 1, $artistItem);
    this->{musicTable}->setItem($currentRow, 2, $albumItem);
    this->{musicTable}->setItem($currentRow, 3, $yearItem);

    if (scalar @{this->{musicTable}->selectedItems()} == 0) {
        this->{musicTable}->selectRow(0);
        this->{mediaObject}->setCurrentSource(this->{metaInformationResolver}->currentSource());
    }

    my $source = this->{metaInformationResolver}->currentSource();
    my $index = indexOfSource(this->{metaInformationResolver}->currentSource()) + 1;
    if (scalar @{this->{sources}} > $index) {
        this->{metaInformationResolver}->setCurrentSource(this->{sources}->[$index]);
    }
    else {
        this->{musicTable}->resizeColumnsToContents();
        if (this->{musicTable}->columnWidth(0) > 300) {
            this->{musicTable}->setColumnWidth(0, 300);
        }
    }
}

sub aboutToFinish
{
    my $index = indexOfSource(this->{mediaObject}->currentSource()) + 1;
    if (scalar @{this->{sources}} > $index) {
        this->{mediaObject}->enqueue(this->{sources}->[$index]);
    }
}

sub setupActions
{
    this->{playAction} = Qt::Action(style()->standardIcon(Qt::Style::SP_MediaPlay()), this->tr('Play'), this);
    this->{playAction}->setShortcut(Qt::KeySequence(this->tr('Ctrl+P')));
    this->{playAction}->setDisabled(1);
    this->{pauseAction} = Qt::Action(style()->standardIcon(Qt::Style::SP_MediaPause()), this->tr('Pause'), this);
    this->{pauseAction}->setShortcut(Qt::KeySequence(this->tr('Ctrl+A')));
    this->{pauseAction}->setDisabled(1);
    this->{stopAction} = Qt::Action(style()->standardIcon(Qt::Style::SP_MediaStop()), this->tr('Stop'), this);
    this->{stopAction}->setShortcut(Qt::KeySequence(this->tr('Ctrl+S')));
    this->{stopAction}->setDisabled(1);
    this->{nextAction} = Qt::Action(style()->standardIcon(Qt::Style::SP_MediaSkipForward()), this->tr('Next'), this);
    this->{nextAction}->setShortcut(Qt::KeySequence(this->tr('Ctrl+N')));
    this->{previousAction} = Qt::Action(style()->standardIcon(Qt::Style::SP_MediaSkipBackward()), this->tr('Previous'), this);
    this->{previousAction}->setShortcut(Qt::KeySequence(this->tr('Ctrl+R')));
    this->{addFilesAction} = Qt::Action(this->tr('Add &Files'), this);
    this->{addFilesAction}->setShortcut(Qt::KeySequence(this->tr('Ctrl+F')));
    this->{exitAction} = Qt::Action(this->tr('E&xit'), this);
    this->{exitAction}->setShortcuts(Qt::KeySequence::Quit());
    this->{aboutAction} = Qt::Action(this->tr('A&bout'), this);
    this->{aboutAction}->setShortcut(Qt::KeySequence(this->tr('Ctrl+B')));
    this->{aboutQtAction} = Qt::Action(this->tr('About &Qt'), this);
    this->{aboutQtAction}->setShortcut(Qt::KeySequence(this->tr('Ctrl+Q')));

    this->connect(this->{playAction}, SIGNAL 'triggered()', this->{mediaObject}, SLOT 'play()');
    this->connect(this->{pauseAction}, SIGNAL 'triggered()', this->{mediaObject}, SLOT 'pause()' );
    this->connect(this->{stopAction}, SIGNAL 'triggered()', this->{mediaObject}, SLOT 'stop()');
    this->connect(this->{addFilesAction}, SIGNAL 'triggered()', this, SLOT 'addFiles()');
    this->connect(this->{exitAction}, SIGNAL 'triggered()', this, SLOT 'close()');
    this->connect(this->{aboutAction}, SIGNAL 'triggered()', this, SLOT 'about()');
    this->connect(this->{aboutQtAction}, SIGNAL 'triggered()', Qt::qApp, SLOT 'aboutQt()');
}

sub setupMenus
{
    my $fileMenu = menuBar()->addMenu(this->tr('&File'));
    $fileMenu->addAction(this->{addFilesAction});
    $fileMenu->addSeparator();
    $fileMenu->addAction(this->{exitAction});

    my $aboutMenu = menuBar()->addMenu(this->tr('&Help'));
    $aboutMenu->addAction(this->{aboutAction});
    $aboutMenu->addAction(this->{aboutQtAction});
}

sub setupUi
{
    my $bar = Qt::ToolBar();

    $bar->addAction(this->{playAction});
    $bar->addAction(this->{pauseAction});
    $bar->addAction(this->{stopAction});

    this->{seekSlider} = Phonon::SeekSlider(this);
    this->{seekSlider}->setMediaObject(this->{mediaObject});

    this->{volumeSlider} = Phonon::VolumeSlider(this);
    this->{volumeSlider}->setAudioOutput(this->{audioOutput});
    this->{volumeSlider}->setSizePolicy(Qt::SizePolicy::Maximum(), Qt::SizePolicy::Maximum());

    my $volumeLabel = Qt::Label();
    $volumeLabel->setPixmap(Qt::Pixmap('images/volume.png'));

    my $palette = Qt::Palette();
    $palette->setBrush(Qt::Palette::Light(), Qt::Brush(Qt::Color(Qt::darkGray())));

    this->{timeLcd} = Qt::LCDNumber();
    this->{timeLcd}->setPalette($palette);

    my @headers = ( this->tr('Title'), this->tr('Artist'), this->tr('Album'),
        this->tr('Year') );

    this->{musicTable} = Qt::TableWidget(0, 4);
    this->{musicTable}->setHorizontalHeaderLabels(\@headers);
    this->{musicTable}->setSelectionMode(Qt::AbstractItemView::SingleSelection());
    this->{musicTable}->setSelectionBehavior(Qt::AbstractItemView::SelectRows());
    this->connect(this->{musicTable}, SIGNAL 'cellPressed(int,int)',
            this, SLOT 'tableClicked(int,int)');

    my $seekerLayout = Qt::HBoxLayout();
    $seekerLayout->addWidget(this->{seekSlider});
    $seekerLayout->addWidget(this->{timeLcd});

    my $playbackLayout = Qt::HBoxLayout();
    $playbackLayout->addWidget($bar);
    $playbackLayout->addStretch();
    $playbackLayout->addWidget($volumeLabel);
    $playbackLayout->addWidget(this->{volumeSlider});

    my $mainLayout = Qt::VBoxLayout();
    $mainLayout->addWidget(this->{musicTable});
    $mainLayout->addLayout($seekerLayout);
    $mainLayout->addLayout($playbackLayout);

    my $widget = Qt::Widget();
    $widget->setLayout($mainLayout);

    setCentralWidget($widget);
    setWindowTitle('Phonon Music Player');
}

1;
