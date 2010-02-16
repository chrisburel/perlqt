use Test::More tests => 6;

use Qt;

no warnings;
$a = Qt::Application( \@ARGV );
use warnings;

$widget = Qt::Widget();

# Test Qt::String marshalling
$wt = 'Qt::String marshalling works!';
$widget->setWindowTitle( $wt );
is ( $widget->windowTitle(), $wt, 'Qt::String' );
# Test a string that has non-latin characters
{
    use utf8;
    $wt = 'ターミナル';
    utf8::upgrade($wt);
    $widget->setWindowTitle( $wt );
    is ( $widget->windowTitle(), $wt, 'Qt::String unicode' );
}

# Test int marshalling
$int = 341;
$widget->resize( $int, $int );
is ( $widget->height(), $int, 'int' );

# Test double marshalling
$double = 3/7;
my $doubleValidator = Qt::DoubleValidator( $double, $double * 2, 5, undef );
is ( $doubleValidator->bottom(), $double, 'double' );
is ( $doubleValidator->top(), $double * 2, 'double' );

# Test bool marshalling
$bool = !$widget->isEnabled();
$widget->setEnabled( $bool );
is ( $widget->isEnabled(), $bool, 'bool' );
