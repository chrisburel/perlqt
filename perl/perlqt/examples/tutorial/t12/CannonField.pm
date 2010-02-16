package CannonField;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw(Qt4::Widget);
use Qt4::slots setAngle  => ['int'],
              setForce  => ['int'],
              shoot     => [],
              newTarget => [],
              moveShot  => [];
use Qt4::signals hit          => [],
                missed       => [],
                angleChanged => ['int'],
                forceChanged => ['int'];

sub NEW {
    shift->SUPER::NEW(@_);

    this->{currentAngle} = 45;
    this->{currentForce} = 0;
    this->{timerCount} = 0;
    my $autoShootTimer = Qt4::Timer(this);
    this->{autoShootTimer} = $autoShootTimer;
    this->connect( $autoShootTimer, SIGNAL 'timeout()', this, SLOT 'moveShot()' );
    this->{shootAngle} = 0;
    this->{shootForce} = 0;
    this->{target} = Qt4::Point(0, 0);
    this->setPalette(Qt4::Palette(Qt4::Color(250,250,200)));
    this->setAutoFillBackground(1);
    this->{firstTime} = 1;
    newTarget();
}

sub setAngle {
    my ( $angle ) = @_;
    if ($angle < 5) {
        $angle = 5;
    }
    if ($angle > 70) {
        $angle = 70;
    }
    if (this->{currentAngle} == $angle) {
        return;
    }
    this->{currentAngle} = $angle;
    this->update(this->cannonRect());
    emit angleChanged( this->{currentAngle} );
}

sub setForce {
    my ( $force ) = @_;
    if ($force < 0) {
        $force = 0;
    }
    if (this->{currentForce} == $force) {
        return;
    }
    this->{currentForce} = $force;
    emit forceChanged( this->{currentForce} );
}

sub shoot {
    my $autoShootTimer = this->{autoShootTimer};
    if ($autoShootTimer->isActive()) {
        return;
    }
    this->{timerCount} = 0;
    this->{shootAngle} = this->{currentAngle};
    this->{shootForce} = this->{currentForce};
    $autoShootTimer->start(5);
}

sub newTarget {
    if (this->{firstTime}) {
        this->{firstTime} = 0;
        srand (time ^ $$ ^ unpack "%L*", `ps axww | gzip -f`);
    }

    # 2147483647 is the value of RAND_MAX, defined in stdlib.h, at least on my machine.
    # See the Qt4 4.2 documentation on qrand() for more details.
    this->{target} = Qt4::Point( 150 + rand(2147483647) % 190, 10 + rand(2147483647) % 255);
    this->update();
}

sub moveShot {
    my $region = shotRect();
    this->{timerCount}++;

    my $shotR = shotRect();

    if ($shotR->intersects(targetRect())) {
        this->{autoShootTimer}->stop();
        emit hit();
    }
    elsif ($shotR->x() > this->width() || $shotR->y() > this->height()) {
        this->{autoShootTimer}->stop();
        emit missed();
    }
    else {
        $region = $region->unite($shotR);
    }
    this->update($region);
}

my $barrelRect = Qt4::Rect(30, -5, 20, 10);

sub paintEvent {
    my $painter = Qt4::Painter(this);

    if (this->{autoShootTimer}->isActive()){
        paintShot($painter);
    }

    paintTarget($painter);

    paintCannon($painter);

    $painter->end();
}

sub paintShot {
    my( $painter ) = @_;
    $painter->setPen(Qt4::NoPen());
    $painter->setBrush(Qt4::Brush(Qt4::black()));
    $painter->drawRect(shotRect());
}

sub paintTarget {
    my( $painter ) = @_;
    $painter->setPen(Qt4::Color(0, 0, 0));
    $painter->setBrush(Qt4::Brush(Qt4::red()));
    $painter->drawRect(targetRect());
}

sub paintCannon {
    my( $painter ) = @_;
    $painter->setPen(Qt4::NoPen());
    $painter->setBrush(Qt4::Brush(Qt4::blue()));

    $painter->translate(0, this->rect()->height());
    $painter->drawPie(Qt4::Rect(-35, -35, 70, 70), 0, 90 * 16);
    $painter->rotate(-(this->{currentAngle}));
    $painter->drawRect($barrelRect);
}

sub cannonRect {
    my $result = Qt4::Rect(0, 0, 50, 50);
    $result->moveBottomLeft(this->rect()->bottomLeft());
    return $result;
}

sub shotRect {
    my $gravity = 4;
    my $time = this->{timerCount} / 20.0;
    my $velocity = this->{shootForce};
    my $radians = this->{shootAngle} * 3.14159265 / 180;

    my $velx = $velocity * cos($radians);
    my $vely = $velocity * sin($radians);
    my $x0 = ($barrelRect->right() + 5) * cos($radians);
    my $y0 = ($barrelRect->right() + 5) * sin($radians);
    my $x = $x0 + $velx * $time;
    my $y = $y0 + $vely * $time - 0.5 * $gravity * $time * $time;

    $x = int($x + .5);
    $y = int($y + .5);

    my $result = Qt4::Rect(0, 0, 6, 6);
    $result->moveCenter(Qt4::Point( $x, this->height() - 1 - $y ));
    return $result;
}

sub targetRect {
    my $result = Qt4::Rect(0, 0, 20, 10);
    my $target = this->{target};
    $result->moveCenter(Qt4::Point($target->x(), this->height() - 1 - $target->y()));
    return $result;
}

1;
