use strict;
use warnings;

use Test::More tests => 23;
use PerlSmokeTest;


package MyVirtualMethodTesterBase;

use Test::More;
use base qw(PerlSmokeTest::VirtualMethodTester);

sub name {
    my ($self, $count) = @_;
    if ($count > 3) {
        # Calling SUPER::name should not recurse back to this method
        return $self->SUPER::name();
    }
    is(scalar @_, 2);
    $self->{nameCalled} += 1;
    # Make sure you can call reimplemented virtual functions recursively
    return $self->name($count + 1);
}

package MyVirtualMethodTester;

use Test::More;
use base qw(MyVirtualMethodTesterBase);

sub name {
    my ($self, $count) = @_;
    isa_ok($self, 'MyVirtualMethodTester');
    $count //= 0;
    return $self->SUPER::name($count);
}

package main;

sub main {
    my $app = MyVirtualMethodTester->new();
    $app->setName('test name');
    is($app->name(), 'test name');
    # Each call to $app->name() calls it 4 times
    is($app->{nameCalled}, 4);

    # Internally, getName calls name.
    is($app->getName(), 'test name');
    is($app->{nameCalled}, 8);

    eval { $app->pureVirtualMethod() } or
        like($@, qr/Unimplemented pure virtual method called: MyVirtualMethodTester::pureVirtualMethod/);
}

main()
