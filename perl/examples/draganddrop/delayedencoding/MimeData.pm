package MimeData;

use strict;
use warnings;
use blib;

use Qt;
use Qt::isa qw( Qt::MimeData );

#[0]
use Qt::signals
    dataRequested => ['QString'];
#[0]

sub NEW {
    shift->SUPER::NEW();
}

#[0]
sub formats {
    return ['image/png'];
}
#[0]

#[1]
sub retrieveData {
    my ($mimeType, $type) = @_;
    emit dataRequested($mimeType);

    return Qt::Variant(this->SUPER->retrieveData($mimeType, $type));
}
#[1]

1;
