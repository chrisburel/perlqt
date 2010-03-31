package MainWindow;

use strict;
use warnings;
use blib;

use Qt4;
use KDEUi4;
use Qt4::isa qw( KDE::XmlGuiWindow );

sub NEW {
    my ( $class ) = @_;
    $class->SUPER::NEW( undef );

    this->{textArea} = KDE::TextEdit(this);
    this->setCentralWidget( this->{textArea} );
    this->setupGUI();
}

1;
