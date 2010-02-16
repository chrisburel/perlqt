use Test::More tests => 10;

use strict;
use warnings;
use Qt;

my $app = Qt::Application( \@ARGV );

{
    my $widget = Qt::Widget();
    # Test Qt::String marshalling
    my $wt = 'Qt::String marshalling works!';
    $widget->setWindowTitle( $wt );
    is ( $widget->windowTitle(), $wt, 'Qt::String' );
}

{
    my $widget = Qt::Widget();
    # Test a string that has non-latin characters
    use utf8;
    my $wt = 'ターミナル';
    utf8::upgrade($wt);
    $widget->setWindowTitle( $wt );
    is ( $widget->windowTitle(), $wt, 'Qt::String unicode' );
}

{
    # Test int marshalling
    my $widget = Qt::Widget();
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
    my $widget = Qt::Widget();
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

{
    # Test unsigned int marshalling
    my $label = Qt::Label();
    my $hcenter = ${Qt::AlignHCenter()};
    my $top = ${Qt::AlignTop()};
    $label->setAlignment(Qt::AlignHCenter() | Qt::AlignTop());
    my $alignment = $label->alignment();
    is( $alignment, $hcenter|$top, 'unsigned int' );
}

{
    # Test some QLists
    my $action1 = Qt::Action( 'foo', undef );
    my $action2 = Qt::Action( 'bar', undef );
    my $action3 = Qt::Action( 'baz', undef );

    # Add some stuff to them...
    $action1->{The} = 'quick';
    $action2->{brown} = 'fox';
    $action3->{jumped} = 'over';

    my $actions = [ $action1, $action2, $action3 ]; 

    my $widget = Qt::Widget();
    $widget->addActions( $actions );

    my $gotactions = $widget->actions();

    is_deeply( $actions, $gotactions, 'marshall_ItemList<>' );
}
