package Dialog;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Dialog );

use WigglyWidget;

# [0]
sub NEW {
    my ( $class, $parent ) = @_;
    $class->SUPER::NEW( $parent );

    my $wigglyWidget = WigglyWidget();
    my $lineEdit = Qt4::LineEdit();

    my $layout = Qt4::VBoxLayout();
    $layout->addWidget($wigglyWidget);
    $layout->addWidget($lineEdit);
    this->setLayout($layout);

    this->connect($lineEdit, SIGNAL 'textChanged(QString)',
            $wigglyWidget, SLOT 'setText(QString)');

    $lineEdit->setText(this->tr("Hello world!"));

    this->setWindowTitle(this->tr("Wiggly"));
    this->resize(360, 145);
}
# [0]

1;
