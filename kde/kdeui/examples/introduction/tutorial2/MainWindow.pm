package MainWindow;

use strict;
use warnings;

use KDEUi4;
use QtCore4::isa qw( KDE::XmlGuiWindow );

sub NEW {
    my ( $class ) = @_;
    $class->SUPER::NEW( undef );

    this->{textArea} = KDE::TextEdit(this);
    this->setCentralWidget( this->{textArea} );
    this->setupGUI();
}

1;
