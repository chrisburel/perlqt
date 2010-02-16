package MyApp;

use Test::More tests => 3;

use Qt;
use Qt::isa qw(Qt::Application);
use Qt::slots
        foo => ['int'],
        baz => [];
use Qt::signals
        bar => ['int'];

sub NEW {
     shift->SUPER::NEW(@_);

     # 1) testing correct subclassing of Qt::Application and this pointer
     is( ref(this), ' MyApp', 'Correct subclassing' );
     
     this->connect(this, SIGNAL 'bar(int)', SLOT 'foo(int)');

     # 3) automatic quitting will test Qt sig to custom slot 
     this->connect(this, SIGNAL 'aboutToQuit()', SLOT 'baz()');

     # 2) testing custom sig to custom slot 
     emit bar(3);
}

sub foo {
    is( $_[0], 3, 'Custom signal to custom slot' );
}

sub baz {
    ok( 1, 'Qt signal to custom slot' );
}     

1;

package main;

use Qt;
use MyApp;

$a = 0;
$a = MyApp(\@ARGV);

Qt::Timer::singleShot( 300, qApp, SLOT "quit()" );

exit qApp->exec;
