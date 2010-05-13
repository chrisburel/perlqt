package TabletApplication;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Application );

sub setCanvas {
    my ($canvas) = @_;
    this->{myCanvas} = $canvas;
}

sub myCanvas() {
    return this->{myCanvas};
}

# [0]
sub event {
    my ($event) = @_;
    if ($event->type() == Qt4::Event::TabletEnterProximity() ||
        $event->type() == Qt4::Event::TabletLeaveProximity()) {
        CAST( $event, 'Qt4::TabletEvent' );
        this->myCanvas->setTabletDevice(
            $event->device());
        return 1;
    }
    return this->SUPER::event($event);
}
# [0]

1;
