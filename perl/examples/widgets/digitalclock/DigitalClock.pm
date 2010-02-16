package DigitalClock;

use strict;
use warnings;
use blib;

use Qt;
use Qt::isa qw( Qt::LCDNumber );
use Qt::slots
    showTime => [];

# [0]

# [0]
sub NEW {
    my ( $class, $parent ) = @_;
    $DB::single=1;
    $class->SUPER::NEW( $parent );
    this->setSegmentStyle(Qt::LCDNumber::Filled());

    my $timer = Qt::Timer(this);
    this->connect($timer, SIGNAL 'timeout()', this, SLOT 'showTime()');
    $timer->start(1000);

    this->showTime();

    this->setWindowTitle(this->tr('Digital Clock'));
    this->resize(150, 60);
}
# [0]

# [1]
sub showTime {
# [1] //! [2]
    my $time = Qt::Time::currentTime();
    my $text;
    if (($time->second() % 2) == 0) {
        $text = $time->toString('hh mm');
    }
    else {
        $text = $time->toString('hh:mm');
    }
    this->display($text);
}
# [2]

1;
