package TetrixWindow;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Widget );
use TetrixBoard;

# [0]
#    TetrixBoard *board;
#    Qt4::Label *nextPieceLabel;
#    Qt4::LCDNumber *scoreLcd;
#    Qt4::LCDNumber *levelLcd;
#    Qt4::LCDNumber *linesLcd;
#    Qt4::PushButton *startButton;
#    Qt4::PushButton *quitButton;
#    Qt4::PushButton *pauseButton;
# [0]

# [0]
sub NEW {
    my( $class, $parent ) = @_;
    $class->SUPER::NEW( $parent );
    my $board = TetrixBoard();
    this->{board} = $board;
# [0]

    my $nextPieceLabel = Qt4::Label();
    this->{nextPieceLabel} = $nextPieceLabel;
    $nextPieceLabel->setFrameStyle(Qt4::Frame::Box() | Qt4::Frame::Raised());
    $nextPieceLabel->setAlignment(Qt4::AlignCenter());
    $board->setNextPieceLabel($nextPieceLabel);

# [1]
    my $scoreLcd = Qt4::LCDNumber(5);
    this->{scoreLcd} = $scoreLcd;
    $scoreLcd->setSegmentStyle(Qt4::LCDNumber::Filled());
# [1]
    my $levelLcd = Qt4::LCDNumber(2);
    this->{levelLcd} = $levelLcd;
    $levelLcd->setSegmentStyle(Qt4::LCDNumber::Filled());
    my $linesLcd = Qt4::LCDNumber(5);
    this->{linesLcd} = $linesLcd;
    $linesLcd->setSegmentStyle(Qt4::LCDNumber::Filled());

# [2]
    my $startButton = Qt4::PushButton(this->tr('&Start'));
    this->{startButton} = $startButton;
    $startButton->setFocusPolicy(Qt4::NoFocus());
    my $quitButton = Qt4::PushButton(this->tr('&Quit'));
    this->{quitButton} = $quitButton;
    $quitButton->setFocusPolicy(Qt4::NoFocus());
    my $pauseButton = Qt4::PushButton(this->tr('&Pause'));
    this->{pauseButton} = $pauseButton;
# [2] //! [3]
    $pauseButton->setFocusPolicy(Qt4::NoFocus());
# [3] //! [4]

    this->connect($startButton, SIGNAL 'clicked()', $board, SLOT 'start()');
# [4] //! [5]
    this->connect($quitButton , SIGNAL 'clicked()', qApp, SLOT 'quit()');
    this->connect($pauseButton, SIGNAL 'clicked()', $board, SLOT 'pause()');
    this->connect($board, SIGNAL 'scoreChanged(int)', $scoreLcd, SLOT 'display(int)');
    this->connect($board, SIGNAL 'levelChanged(int)', $levelLcd, SLOT 'display(int)');
    this->connect($board, SIGNAL 'linesRemovedChanged(int)',
            $linesLcd, SLOT 'display(int)');
# [5]

# [6]
    my $layout = Qt4::GridLayout();
    $layout->addWidget(createLabel(this->tr('NEXT')), 0, 0);
    $layout->addWidget($nextPieceLabel, 1, 0);
    $layout->addWidget(createLabel(this->tr('LEVEL')), 2, 0);
    $layout->addWidget($levelLcd, 3, 0);
    $layout->addWidget($startButton, 4, 0);
    $layout->addWidget($board, 0, 1, 6, 1);
    $layout->addWidget(createLabel(this->tr('SCORE')), 0, 2);
    $layout->addWidget($scoreLcd, 1, 2);
    $layout->addWidget(createLabel(this->tr('LINES REMOVED')), 2, 2);
    $layout->addWidget($linesLcd, 3, 2);
    $layout->addWidget($quitButton, 4, 2);
    $layout->addWidget($pauseButton, 5, 2);
    this->setLayout($layout);

    this->setWindowTitle(this->tr('Tetrix'));
    this->resize(550, 370);
}
# [6]

# [7]
sub createLabel {
    my ( $text ) = @_;
    my $lbl = Qt4::Label($text);
    $lbl->setAlignment(Qt4::AlignHCenter() | Qt4::AlignBottom());
    return $lbl;
}
# [7]

1;
