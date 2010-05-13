package NewAddressTab;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Widget );
use Qt4::slots
    addEntry => [];

use Qt4::signals
    sendDetails => ['QString', 'QString'];

use AddDialog;

sub NEW {
    my ( $class, $parent ) = @_;
    $class->SUPER::NEW( $parent );

    my $descriptionLabel = Qt4::Label(this->tr('There are currently no contacts in your address book. ' .
                                      "\nClick Add to add new contacts."));
    
    my $addButton = Qt4::PushButton(this->tr('Add'));
    
    this->connect($addButton, SIGNAL 'clicked()', this, SLOT 'addEntry()');
    
    my $mainLayout = Qt4::VBoxLayout();
    $mainLayout->addWidget($descriptionLabel);
    $mainLayout->addWidget($addButton, 0, Qt4::AlignCenter());
    
    this->setLayout($mainLayout);
}

sub addEntry {
    my $aDialog = AddDialog();
    
    if ($aDialog->exec()) {
        my $name = $aDialog->nameText()->text();
        my $address = $aDialog->addressText()->toPlainText();
        
        emit sendDetails($name, $address);
    }
}

1;
