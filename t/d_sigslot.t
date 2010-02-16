package MyApp;

use Test::More tests => 4;

use Qt;
use Qt::isa qw(Qt::Application);
use Qt::slots
        foo => [],
        slotToSignal => ['int','int'],
        slot => ['int','int'];
use Qt::signals
        signal => ['int','int'],
        signalFromSlot => ['int','int'];

sub NEW {
    shift->SUPER::NEW(@_);

    # 1) testing correct subclassing of Qt::Application and this pointer
    is( ref(this), ' MyApp', 'Correct subclassing' );

    this->connect(this, SIGNAL 'signal(int,int)', SLOT 'slotToSignal(int,int)');
    this->connect(this, SIGNAL 'signalFromSlot(int,int)', SLOT 'slot(int,int)');

    # 4) automatic quitting will test Qt sig to custom slot 
    this->connect(this, SIGNAL 'aboutToQuit()', SLOT 'foo()');

    # 2) Emit a signal to a slot that will emit another signal
    emit signal( 5, 4 );
}

sub foo {
    is( scalar @_, 0, 'Qt signal to custom slot' );
}     

sub slotToSignal {
    is_deeply( \@_, [ 5, 4 ], 'Custom signal to custom slot' );
    # 3) Emit a signal to a slot from within a signal
    emit signalFromSlot( @_ );
}

sub slot {
    is_deeply( \@_, [ 5, 4 ], 'Signal to slot to signal to slot' );
}

1;

package main;

use Qt;
use MyApp;

$a = MyApp(\@ARGV);

Qt::Timer::singleShot( 300, $a, SLOT "quit()" );

exit $a->exec;
