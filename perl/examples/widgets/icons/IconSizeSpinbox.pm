package IconSizeSpinbox;

use strict;
use warnings;
use blib;

use Qt;

# [0]
use Qt::isa qw( Qt::SpinBox );
# [0]

# [0]
sub NEW {
    my ( $class, $parent ) = @_;
    $class->SUPER::NEW( $parent );
}
# [0]

# [1]
sub valueFromText {
    my ($text) = @_;

    my $regExp = Qt::RegExp(this->tr('(\\d+)(\\s*[xx]\\s*\\d+)?'));

    if ($regExp->exactMatch($text)) {
        return $regExp->cap(1).toInt();
    } else {
        return 0;
    }
}
# [1]

# [2]
sub textFromValue {
    my ( $value ) = @_;
    return sprintf this->tr('%d x %d'), $value;
}
# [2]

1;
