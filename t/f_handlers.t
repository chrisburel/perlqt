use Test::More tests => 8;

use strict;
use warnings;
use Qt;

my $app = Qt::Application( \@ARGV );

my $widget = Qt::Widget();

{
    # Test Qt::String marshalling
    my $wt = 'Qt::String marshalling works!';
    $widget->setWindowTitle( $wt );
    is ( $widget->windowTitle(), $wt, 'Qt::String' );
}

{
    # Test a string that has non-latin characters
    use utf8;
    my $wt = 'ターミナル';
    utf8::upgrade($wt);
    $widget->setWindowTitle( $wt );
    is ( $widget->windowTitle(), $wt, 'Qt::String unicode' );
}

{
    # Test int marshalling
    my $int = 341;
    $widget->resize( $int, $int );
    is ( $widget->height(), $int, 'int' );

    # Test marshalling to int from enum value
    my $textFormat = Qt::TextCharFormat();
    $textFormat->setFontWeight( Qt::Font::Bold() );
    is ( $textFormat->fontWeight(), ${Qt::Font::Bold()}, 'enum to int' );
}

{
    # Test double marshalling
    my $double = 3/7;
    my $doubleValidator = Qt::DoubleValidator( $double, $double * 2, 5, undef );
    is ( $doubleValidator->bottom(), $double, 'double' );
    is ( $doubleValidator->top(), $double * 2, 'double' );
}

{
    # Test bool marshalling
    my $bool = !$widget->isEnabled();
    $widget->setEnabled( $bool );
    is ( $widget->isEnabled(), $bool, 'bool' );
}

{
    # Test int* marshalling
    my ( $x1, $y1, $w1, $h1, $x2, $y2, $w2, $h2 ) = ( 5, 4, 50, 40 );
    $x1 = 5;
    $y1 = 4;
    $w1 = 50;
    $h1 = 40;
    my $rect = Qt::Rect( $x1, $y1, $w1, $h1 );
    $rect->getRect( $x2, $y2, $w2, $h2 );
    ok ( $x1 == $x2 &&
         $y1 == $y2 &&
         $w1 == $w2 &&
         $h1 == $h2,
         'int*' );
}

