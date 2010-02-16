package AnalogClock;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Widget );
use List::Util qw( min );

my $hourHand = [
    Qt4::Point(7, 8),
    Qt4::Point(-7, 8),
    Qt4::Point(0, -40)
];

my $minuteHand = [
    Qt4::Point(7, 8),
    Qt4::Point(-7, 8),
    Qt4::Point(0, -70)
];

# [0] //! [1]
sub NEW {
    my ( $class, $parent ) = @_;
# [0] //! [2]
    $class->SUPER::NEW( $parent );
# [2] //! [3]
# [3] //! [4]
    my $timer = Qt4::Timer(this);
# [4] //! [5]
    this->connect($timer, SIGNAL 'timeout()', this, SLOT 'update()');
# [5] //! [6]
    $timer->start(1000);
# [6]

    this->setWindowTitle(this->tr("Analog Clock"));
    this->resize(200, 200);
# [7]
}
# [1] //! [7]

# [8] //! [9]
sub paintEvent {
# [8] //! [10]

    my $hourColor = Qt4::Color(127, 0, 127);
    my $minuteColor = Qt4::Color(0, 127, 127, 191);

    my $side = min(this->width(), this->height());
    my $time = Qt4::Time::currentTime();
# [10]

# [11]
    my $painter = Qt4::Painter(this);
# [11] //! [12]
    $painter->setRenderHint(Qt4::Painter::Antialiasing());
# [12] //! [13]
    $painter->translate(this->width() / 2, this->height() / 2);
# [13] //! [14]
    $painter->scale($side / 200.0, $side / 200.0);
# [9] //! [14]

# [15]
    $painter->setPen(Qt4::NoPen());
# [15] //! [16]
    $painter->setBrush(Qt4::Brush($hourColor));
# [16]

# [17] //! [18]
    $painter->save();
# [17] //! [19]
    $painter->rotate(30.0 * (($time->hour() + $time->minute() / 60.0)));
    # XXX This should work by doing drawConvexPolygon( $hourHand, 3 ), but that
    # method seems to be incorrect in smoke.
    $painter->drawConvexPolygon(Qt4::Polygon($hourHand));
    $painter->restore();
# [18] //! [19]

# [20]
    $painter->setPen($hourColor);
# [20] //! [21]

    for (my $i = 0; $i < 12; ++$i) {
        $painter->drawLine(88, 0, 96, 0);
        $painter->rotate(30.0);
    }
# [21]

# [22]
    $painter->setPen(Qt4::NoPen());
# [22] //! [23]
    $painter->setBrush(Qt4::Brush($minuteColor));

# [24]
    $painter->save();
    $painter->rotate(6.0 * ($time->minute() + $time->second() / 60.0));
    $painter->drawConvexPolygon(Qt4::Polygon($minuteHand));
    $painter->restore();
# [23] //! [24]

# [25]
    $painter->setPen($minuteColor);
# [25] //! [26]

# [27]
    for (my $j = 0; $j < 60; ++$j) {
        if (($j % 5) != 0) {
            $painter->drawLine(92, 0, 96, 0);
        }
        $painter->rotate(6.0);
    }

    $painter->end();
# [27]
}
# [26]

1;
