package SvgTextObject;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::Object, Qt4::TextObjectInterface );
    #Q_INTERFACES(Qt4::TextObjectInterface)

use constant SvgData => 1;

sub NEW {
    my ( $class ) = @_;
    $class->SUPER::NEW();
}

#[0]
sub intrinsicSize
{
    my $format = $_[2];
    my $bufferedImage = $format->property(SvgData)->value();
    my $size = $bufferedImage->size();
    
    if ($size->height() > 25) {
        $size *= 25.0 / $size->height();
    }

    return Qt4::SizeF($size);
}
#[0]

#[1]
sub drawObject
{
    my ($painter, $rect, $format) = @_[0,1,4];
    my $bufferedImage = $format->property(SvgData)->value();

    $painter->drawImage($rect, $bufferedImage);
}
#[1]

1;
