package GameBoard;

use strict;
use blib;

use Qt4;
use Qt4::isa qw(Qt4::Widget);
use Qt4::slots fire    => [],
              hit     => [],
              missed  => [],
              newGame => [];

use CannonField;
use LCDRange;

my @widgets;

sub NEW {
    shift->SUPER::NEW(@_);

    my $quit = Qt4::PushButton("&Quit");
    $quit->setFont(Qt4::Font("Times", 18, Qt4::Font::Bold()));

    this->connect($quit, SIGNAL "clicked()", qApp, SLOT "quit()");

    my $angle = LCDRange(undef, "ANGLE");
    $angle->setRange(5, 70);

    my $force = LCDRange(undef, "FORCE");
    $force->setRange(10, 50);

    my $cannonBox = Qt4::Frame();
    $cannonBox->setFrameStyle(CAST Qt4::Frame::WinPanel() | Qt4::Frame::Sunken(), 'Qt4::WindowFlags');

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

    my $shoot = Qt4::PushButton("&Shoot");
    $shoot->setFont(Qt4::Font("Times", 18, Qt4::Font::Bold()));

    this->connect($shoot, SIGNAL 'clicked()',
                  this, SLOT 'fire()');
    this->connect($cannonField, SIGNAL 'canShoot(bool)',
                  $shoot, SLOT 'setEnabled(bool)');

    my $restart = Qt4::PushButton("&New Game");
    $restart->setFont(Qt4::Font("Times", 18, Qt4::Font::Bold()));

    this->connect($restart, SIGNAL 'clicked()', this, SLOT 'newGame()');

    my $hits = Qt4::LCDNumber(2);
    $hits->setSegmentStyle(Qt4::LCDNumber::Filled());

    my $shotsLeft = Qt4::LCDNumber(2);
    $shotsLeft->setSegmentStyle(Qt4::LCDNumber::Filled());

    my $hitsLabel = Qt4::Label("HITS");
    my $shotsLeftLabel = Qt4::Label("SHOTS LEFT");

    Qt4::Shortcut(Qt4::KeySequence(${Qt4::Key_Enter()}), this, SLOT 'fire()');
    Qt4::Shortcut(Qt4::KeySequence(${Qt4::Key_Return()}), this, SLOT 'fire()');
    Qt4::Shortcut(Qt4::KeySequence(${Qt4::CTRL() + Qt4::Key_Q()}), this, SLOT 'close()');

    my $topLayout = Qt4::HBoxLayout();
    $topLayout->addWidget($shoot);
    $topLayout->addWidget($hits);
    $topLayout->addWidget($hitsLabel);
    $topLayout->addWidget($shotsLeft);
    $topLayout->addWidget($shotsLeftLabel);
    $topLayout->addStretch(1);
    $topLayout->addWidget($restart);

    my $leftLayout = Qt4::VBoxLayout();
    $leftLayout->addWidget($angle);
    $leftLayout->addWidget($force);

    my $cannonLayout = Qt4::VBoxLayout();
    $cannonLayout->addWidget($cannonField);
    $cannonBox->setLayout($cannonLayout);

    my $gridLayout = Qt4::GridLayout();
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
