use strict;
use warnings;

use Test::More;

use PerlSmokeTest;

my $testData = [
    ['Char', 'a', \&is, 'char handler'],
    ['Char', ord('a'), \&is, 'char handler - as int', 'a'],
    ['Char', undef, \&is, 'char handler - undef', "\0"],
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

