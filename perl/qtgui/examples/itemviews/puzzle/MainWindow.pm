package MainWindow;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::MainWindow );
use Qt4::slots
    openImage => [],
    setupPuzzle => [],
    setCompleted => [];
use PiecesModel;
use PuzzleWidget;
use List::Util qw( min );

sub puzzleImage() {
    return this->{puzzleImage};
}

sub piecesList() {
    return this->{piecesList};
}

sub puzzleWidget() {
    return this->{puzzleWidget};
}

sub model() {
    return this->{model};
}

sub NEW
{
    my ( $class, $parent ) = @_;
    $class->SUPER::NEW( $parent );
    this->setupMenus();
    this->setupWidgets();
    this->{model} = PiecesModel(this);
    this->piecesList->setModel(this->model);

    this->setSizePolicy(Qt4::SizePolicy(Qt4::SizePolicy::Fixed(), Qt4::SizePolicy::Fixed()));
    this->setWindowTitle(this->tr('Puzzle'));
}

sub openImage
{
    my ($path) = @_;
    my $fileName = $path;

    if (!$fileName) {
        $fileName = Qt4::FileDialog::getOpenFileName(this,
            this->tr('Open Image'), '', this->tr('Image Files (*.png *.jpg *.bmp)'));
    }

    if ($fileName) {
        my $newImage = Qt4::Pixmap();
        if (!$newImage->load($fileName)) {
            Qt4::MessageBox::warning(this, this->tr('Open Image'),
                                 this->tr('The image file could not be loaded.'),
                                 Qt4::MessageBox::Cancel());
            return;
        }
        this->{puzzleImage} = $newImage;
        this->setupPuzzle();
    }
}

sub setCompleted
{
    Qt4::MessageBox::information(this, this->tr('Puzzle Completed'),
        this->tr("Congratulations! You have completed the puzzle!\n" .
           'Click OK to start again.'),
        Qt4::MessageBox::Ok());

    this->setupPuzzle();
}

sub setupPuzzle
{
    my $size = min(this->puzzleImage->width(), this->puzzleImage->height());
    this->{puzzleImage} = this->puzzleImage->copy((this->puzzleImage->width() - $size)/2,
        (this->puzzleImage->height() - $size)/2, $size, $size)->scaled(400,
            400, Qt4::IgnoreAspectRatio(), Qt4::SmoothTransformation());

    srand(Qt4::Cursor::pos()->x() ^ Qt4::Cursor::pos()->y());


    this->model->addPieces(this->puzzleImage);
    this->puzzleWidget->clear();
}

sub setupMenus
{
    my $fileMenu = this->menuBar()->addMenu(this->tr('&File'));

    my $openAction = $fileMenu->addAction(this->tr('&Open...'));
    $openAction->setShortcut(Qt4::KeySequence(this->tr('Ctrl+O')));

    my $exitAction = $fileMenu->addAction(this->tr('E&xit'));
    $exitAction->setShortcut(Qt4::KeySequence(this->tr('Ctrl+Q')));

    my $gameMenu = this->menuBar()->addMenu(this->tr('&Game'));

    my $restartAction = $gameMenu->addAction(this->tr('&Restart'));

    this->connect($openAction, SIGNAL 'triggered()', this, SLOT 'openImage()');
    this->connect($exitAction, SIGNAL 'triggered()', qApp, SLOT 'quit()');
    this->connect($restartAction, SIGNAL 'triggered()', this, SLOT 'setupPuzzle()');
}

sub setupWidgets
{
    my $frame = Qt4::Frame();
    my $frameLayout = Qt4::HBoxLayout($frame);

    my $piecesList = this->{piecesList} = Qt4::ListView();
    $piecesList->setDragEnabled(1);
    $piecesList->setViewMode(Qt4::ListView::IconMode());
    $piecesList->setIconSize(Qt4::Size(60, 60));
    $piecesList->setGridSize(Qt4::Size(80, 80));
    $piecesList->setSpacing(10);
    $piecesList->setMovement(Qt4::ListView::Snap());
    $piecesList->setAcceptDrops(1);
    $piecesList->setDropIndicatorShown(1);

    my $model = PiecesModel(this);
    this->piecesList->setModel($model);

    this->{puzzleWidget} = PuzzleWidget();

    this->connect(this->puzzleWidget, SIGNAL 'puzzleCompleted()',
            this, SLOT 'setCompleted()', Qt4::QueuedConnection());

    $frameLayout->addWidget($piecesList);
    $frameLayout->addWidget(this->puzzleWidget);
    this->setCentralWidget($frame);
}

1;
