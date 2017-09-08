use strict;
use warnings;

use POSIX;
use Test::More;

use PerlSmokeTest;

sub isClose {
    my ($got, $expected, $message) = @_;
    ok(abs($got - $expected) < 1e-7, $message);
}

my $testData = [
    ['Bool', 1, \&is, 'bool handler - true value'],
    ['Bool', 0, \&is, 'bool handler - false value', ''],
    ['Bool', undef, \&is, 'bool handler - undef is false', ''],
    ['Char', 'a', \&is, 'char handler'],
    ['Char', ord('a'), \&is, 'char handler - as int', 'a'],
    ['Char', undef, \&is, 'char handler - undef', "\0"],
    ['Double', 0.1, \&isClose, 'double handler'],
    ['Double', POSIX::DBL_MIN, \&isClose, 'double handler - min value'],
    ['Double', POSIX::DBL_MAX, \&isClose, 'double handler - max value'],
    ['Double', undef, \&isClose, 'double handler - undef', 0],
    ['Float', 0.1, \&isClose, 'float handler'],
    ['Float', POSIX::FLT_MIN, \&isClose, 'float handler - min value'],
    ['Float', POSIX::FLT_MAX, \&isClose, 'float handler - max value'],
    ['Float', undef, \&isClose, 'float handler - undef', 0],
    ['Int', 42, \&is, 'int handler'],
    ['Int', \42, \&is, 'int handler - reference', 42],
    ['Int', POSIX::INT_MIN, \&is, 'int handler - min value'],
    ['Int', POSIX::INT_MAX, \&is, 'int handler - max value'],
    ['Int', undef, \&is, 'int handler - undef', 0],
];

sub runTestsWithData {
    my ($testData) = @_;
    foreach my $datum (@{$testData}) {
        my $testHandler = PerlSmokeTest::HandlersTester->new();
        my ($funcName, $value, $cmp, $testName, $expected) = @{$datum};
        if (not defined $expected) {
            $expected = $value;
        }
        my $getter = 'get' . $funcName;
        my $setter = 'set' . $funcName;

        $testHandler->$setter($value);

        $cmp->($testHandler->$getter(), $expected, $testName);
    }
}

plan tests => scalar @{$testData};
runTestsWithData($testData);

