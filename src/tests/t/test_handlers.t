use strict;
use warnings;

use POSIX;
use Test::More;

use PerlSmokeTest;

sub isClose {
    my ($got, $expected, $message) = @_;
    ok(abs($got - $expected) < 1e-7, $message);
}

sub getTemporaryString {
    return "String with SVs_TEMP set";
}

use constant {
    CONST_INT_VALUE => 72
};

my $testData = [
    ['Bool', 1, \&is, 'bool handler - true value'],
    ['Bool', 0, \&is, 'bool handler - false value', ''],
    ['Bool', undef, \&is, 'bool handler - undef is false', ''],
    ['Char', 'a', \&is, 'char handler', ord('a')],
    ['Char', ord('a'), \&is, 'char handler - as int', ord('a')],
    ['Char', POSIX::CHAR_MIN, \&is, 'char handler - min value'],
    ['Char', POSIX::CHAR_MAX, \&is, 'char handler - max value'],
    ['Char', undef, \&is, 'char handler - undef', 0],
    ['CharStar', 'Hello, world!', \&is, 'char* handler'],
    ['CharStar', \&getTemporaryString, \&is, 'char* handler - temporary'],
    ['UnsignedChar', 'a', \&is, 'unsigned char handler', ord('a')],
    ['UnsignedChar', ord('a'), \&is, 'unsigned char handler - as int', ord('a')],
    ['UnsignedChar', -127, \&is, 'unsigned char handler - negative values', 256-127],
    ['UnsignedChar', POSIX::UCHAR_MAX, \&is, 'unsigned char handler - max value'],
    ['UnsignedChar', undef, \&is, 'unsigned char handler - undef', 0],
    ['Double', 0.1, \&isClose, 'double handler'],
    ['Double', POSIX::DBL_MIN, \&isClose, 'double handler - min value'],
    ['Double', POSIX::DBL_MAX, \&isClose, 'double handler - max value'],
    ['Double', undef, \&isClose, 'double handler - undef', 0],
    ['Double', '__magical_number__', \&is, 'double handler - value with get magic', 4],
    ['Float', 0.1, \&isClose, 'float handler'],
    ['Float', POSIX::FLT_MIN, \&isClose, 'float handler - min value'],
    ['Float', POSIX::FLT_MAX, \&isClose, 'float handler - max value'],
    ['Float', undef, \&isClose, 'float handler - undef', 0],
    ['Float', '__magical_number__', \&is, 'float handler - value with get magic', 4],
    ['Int', 42, \&is, 'int handler'],
    ['Int', \42, \&is, 'int handler - reference', 42],
    ['Int', POSIX::INT_MIN, \&is, 'int handler - min value'],
    ['Int', POSIX::INT_MAX, \&is, 'int handler - max value'],
    ['Int', undef, \&is, 'int handler - undef', 0],
    ['Int', '__magical_number__', \&is, 'int handler - value with get magic', 4],
    ['UnsignedInt', 42, \&is, 'unsigned int handler'],
    ['UnsignedInt', \42, \&is, 'unsigned int handler - reference', 42],
    ['UnsignedInt', POSIX::UINT_MAX, \&is, 'unsigned int handler - max value'],
    ['UnsignedInt', undef, \&is, 'unsigned int handler - undef', 0],
    ['UnsignedInt', '__magical_number__', \&is, 'unsigned int handler - value with get magic', 4],
    ['ConstIntRef', 5, \&is, 'const int& handler'],
    ['ConstIntRef', '__magical_number__', \&is, 'const int& handler - value with get magic', 4],
    ['IntStar', \CONST_INT_VALUE, \&is, 'int* handler - readonly value', CONST_INT_VALUE],
    ['IntStar', undef, \&is, 'int* handler - undef'],
    ['IntStar', '__magical_number__', \&is, 'int* handler - value with get magic', 4],
    ['IntStarMultBy2Mutate', 5, \&is, 'int* handler - mutate', 10],
    ['IntStarMultBy2Mutate', \CONST_INT_VALUE, \&is, 'int& handler - readonly value'],
    ['IntRefMultBy2Mutate', 5, \&is, 'int& handler - mutate', 10],
    ['Long', 42, \&is, 'long handler'],
    ['Long', POSIX::LONG_MIN, \&is, 'long handler - min value'],
    ['Long', POSIX::LONG_MAX, \&is, 'long handler - max value'],
    ['Long', undef, \&is, 'long handler - undef', 0],
    ['Long', '__magical_number__', \&is, 'long handler - value with get magic', 4],
    ['UnsignedLong', 42, \&is, 'unsigned long handler'],
    ['UnsignedLong', POSIX::ULONG_MAX, \&is, 'unsigned long handler - max value'],
    ['UnsignedLong', undef, \&is, 'unsigned long handler - undef', 0],
    ['UnsignedLong', '__magical_number__', \&is, 'unsigned long handler - value with get magic', 4],
    ['Short', 42, \&is, 'short handler'],
    ['Short', \42, \&is, 'short handler - reference', 42],
    ['Short', POSIX::SHRT_MIN, \&is, 'short handler - min value'],
    ['Short', POSIX::SHRT_MAX, \&is, 'short handler - max value'],
    ['Short', undef, \&is, 'short handler - undef', 0],
    ['Short', '__magical_number__', \&is, 'short handler - value with get magic', 4],
    ['UnsignedShort', 42, \&is, 'unsigned short handler'],
    ['UnsignedShort', \42, \&is, 'unsigned short handler - reference', 42],
    ['UnsignedShort', POSIX::USHRT_MAX, \&is, 'unsigned short handler - max value'],
    ['UnsignedShort', undef, \&is, 'unsigned short handler - undef', 0],
    ['UnsignedShort', '__magical_number__', \&is, 'unsigned short handler - value with get magic', 4],
];

sub runTestsWithData {
    my ($testData) = @_;
    foreach my $datum (@{$testData}) {
        my $testHandler = PerlSmokeTest::HandlersTester->new();
        my ($funcName, $value, $cmp, $testName, $expected) = @{$datum};
        if (scalar (@{$datum}) < 5) {
            if (ref ($value) eq 'CODE') {
                $expected = $value->();
            }
            else {
                $expected = $value;
            }
        }
        my $getter = 'get' . $funcName;
        my $setter = 'set' . $funcName;

        if (ref ($value) eq 'CODE') {
            # Pass the result of a subroutine call to the setter, so that
            # SVt_TEMP is set on the variable going in
            $testHandler->$setter($value->());
        }
        elsif (defined $value and $value eq '__magical_number__') {
            my @array = qw(a b c d e);
            $testHandler->$setter($#array);
        }
        else {
            $testHandler->$setter($value);
        }

        my $got;
        if ($funcName =~ m/Mutate$/) {
            # Mutate methods modify the input $value directly
            $got = $value;
        }
        else {
            # Non-mutate methods can be checked by calling the corresponding
            # getter
            $got = $testHandler->$getter();
        }
        $cmp->($got, $expected, $testName);
    }
}

plan tests => scalar @{$testData};
runTestsWithData($testData);
