package AddDialog;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Dialog );

sub NEW {
    my ( $class, $parent ) = @_;
    $class->SUPER::NEW( $parent );

    my $nameLabel = Qt4::Label("Name");
    my $addressLabel = Qt4::Label("Address");
    my $okButton = Qt4::PushButton("OK");
    my $cancelButton = Qt4::PushButton("Cancel");
    
    my $nameText = Qt4::LineEdit();
    my $addressText = Qt4::TextEdit();

    this->{nameLabel}    = $nameLabel;
    this->{addressLabel} = $addressLabel;
    this->{okButton}     = $okButton;
    this->{cancelButton} = $cancelButton;
    this->{nameText}     = $nameText;
    this->{addressText}  = $addressText;
    
    my $gLayout = Qt4::GridLayout();
    $gLayout->setColumnStretch(1, 2);
    $gLayout->addWidget($nameLabel, 0, 0);
    $gLayout->addWidget($nameText, 0, 1);
    
    $gLayout->addWidget($addressLabel, 1, 0, Qt4::AlignLeft()|Qt4::AlignTop());
    $gLayout->addWidget($addressText, 1, 1, Qt4::AlignLeft());
    
    my $buttonLayout = Qt4::HBoxLayout();
    $buttonLayout->addWidget($okButton);
    $buttonLayout->addWidget($cancelButton);
    
    $gLayout->addLayout($buttonLayout, 2, 1, Qt4::AlignRight());
    
    my $mainLayout = Qt4::VBoxLayout();
    $mainLayout->addLayout($gLayout);
    this->setLayout($mainLayout);
    
    this->connect($okButton, SIGNAL 'clicked()',
            this, SLOT 'accept()');
            
    this->connect($cancelButton, SIGNAL 'clicked()',
            this, SLOT 'reject()');
            
    this->setWindowTitle(this->tr('Add a Contact'));
}

sub nameText {
    return this->{nameText};
}

sub addressText {
    return this->{addressText};
}

1;
