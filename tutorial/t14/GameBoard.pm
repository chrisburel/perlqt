package GameBoard;

use strict;
use blib;

use Qt;
use Qt::isa qw(Qt::QWidget);
use Qt::slots fire    => [],
              hit     => [],
              missed  => [],
              newGame => [];

use CannonField;
use LCDRange;

my @widgets;

sub NEW {
    shift->SUPER::NEW(@_);

    my $quit = Qt::QPushButton("&Quit");
    $quit->setFont(Qt::QFont("Times", 18, Qt::QFont::Bold()));

    this->connect($quit, SIGNAL "clicked()", Qt::qapp(), SLOT "quit()");

    my $angle = LCDRange(undef, "ANGLE");
    $angle->setRange(5, 70);

    my $force = LCDRange(undef, "FORCE");
    $force->setRange(10, 50);

    my $cannonBox = Qt::QFrame();
    $cannonBox->setFrameStyle(CAST Qt::QFrame::WinPanel() | Qt::QFrame::Sunken(), 'Qt::WindowFlags');

    my $cannonField = CannonField();

    this->connect($angle, SIGNAL 'valueChanged(int)',
                  $cannonField, SLOT 'setAngle(int)');
    this->connect($cannonField, SIGNAL 'angleChanged(int)',
                  $angle, SLOT 'setValue(int)');

    this->connect($force, SIGNAL 'valueChanged(int)',
                  $cannonField, SLOT 'setForce(int)');
    this->connect($cannonField, SIGNAL 'forceChanged(int)',
                  $force, SLOT 'setValue(int)');

    this->connect($cannonField, SIGNAL 'hit()',
                  this, SLOT 'hit()');
    this->connect($cannonField, SIGNAL 'missed()',
                  this, SLOT 'missed()');

    my $shoot = Qt::QPushButton("&Shoot");
    $shoot->setFont(Qt::QFont("Times", 18, Qt::QFont::Bold()));

    this->connect($shoot, SIGNAL 'clicked()',
                  this, SLOT 'fire()');
    this->connect($cannonField, SIGNAL 'canShoot(bool)',
                  $shoot, SLOT 'setEnabled(bool)');

    my $restart = Qt::QPushButton("&New Game");
    $restart->setFont(Qt::QFont("Times", 18, Qt::QFont::Bold()));

    this->connect($restart, SIGNAL 'clicked()', this, SLOT 'newGame()');

    my $hits = Qt::QLCDNumber(2);
    $hits->setSegmentStyle(Qt::QLCDNumber::Filled());

    my $shotsLeft = Qt::QLCDNumber(2);
    $shotsLeft->setSegmentStyle(Qt::QLCDNumber::Filled());

    my $hitsLabel = Qt::QLabel("HITS");
    my $shotsLeftLabel = Qt::QLabel("SHOTS LEFT");

    Qt::QShortcut(Qt::QKeySequence(Qt::Qt::Key_Enter()), this, SLOT 'fire()');
    Qt::QShortcut(Qt::QKeySequence(Qt::Qt::Key_Return()), this, SLOT 'fire()');
    Qt::QShortcut(Qt::QKeySequence(Qt::Qt::CTRL() + Qt::Qt::Key_Q()), this, SLOT 'close()');

    my $topLayout = Qt::QHBoxLayout();
    $topLayout->addWidget($shoot);
    $topLayout->addWidget($hits);
    $topLayout->addWidget($hitsLabel);
    $topLayout->addWidget($shotsLeft);
    $topLayout->addWidget($shotsLeftLabel);
    $topLayout->addStretch(1);
    $topLayout->addWidget($restart);

    my $leftLayout = Qt::QVBoxLayout();
    $leftLayout->addWidget($angle);
    $leftLayout->addWidget($force);

    my $cannonLayout = Qt::QVBoxLayout();
    $cannonLayout->addWidget($cannonField);
    $cannonBox->setLayout($cannonLayout);

    my $gridLayout = Qt::QGridLayout();
    $gridLayout->addWidget($quit, 0, 0);
    $gridLayout->addLayout($topLayout, 0, 1);
    $gridLayout->addLayout($leftLayout, 1, 0);
    $gridLayout->addWidget($cannonBox, 1, 1, 2, 1);
    $gridLayout->setColumnStretch(1, 10);
    this->setLayout($gridLayout);

    $angle->setValue(60);
    $force->setValue(25);
    $angle->setFocus();

    this->{angle} = $angle;
    this->{force} = $force;
    this->{cannonField} = $cannonField;
    this->{cannonBox} = $cannonBox;
    this->{shoot} = $shoot;
    this->{restart} = $restart;
    this->{hits} = $hits;
    this->{shotsLeft} = $shotsLeft;

    newGame();
}

sub fire {
    return if(this->{cannonField}->{gameEnded} || this->{cannonField}->isShooting());
    this->{shotsLeft}->display(this->{shotsLeft}->intValue() - 1);
    this->{cannonField}->shoot();
}

sub hit {
    this->{hits}->display(this->{hits}->intValue() + 1);
    if (this->{shotsLeft}->intValue() == 0) {
        this->{cannonField}->setGameOver();
    }
    else {
        this->{cannonField}->newTarget();
        emit this->{cannonField}->canShoot( 1 );
    }
}

sub missed {
    if (this->{shotsLeft}->intValue() == 0) {
        this->{cannonField}->setGameOver();
    }
}

sub newGame {
    this->{shotsLeft}->display(15);
    this->{hits}->display(0);
    this->{cannonField}->restartGame();
    this->{cannonField}->newTarget();
}

1;
