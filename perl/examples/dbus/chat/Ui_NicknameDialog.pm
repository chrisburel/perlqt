
=begin

** Form generated from reading ui file 'chatsetnickname.ui'
**
** Created: Tue Sep 22 18:41:05 2009
**      by: Qt User Interface Compiler version 4.4.3
**
** WARNING! All changes made in this file will be lost when recompiling ui file!

=cut

package Ui_NicknameDialog;

use strict;
use warnings;
use utf8;
use Qt;

sub vboxLayout {
    return shift->{vboxLayout};
}

sub vboxLayout1 {
    return shift->{vboxLayout1};
}

sub label {
    return shift->{label};
}

sub nickname {
    return shift->{nickname};
}

sub hboxLayout {
    return shift->{hboxLayout};
}

sub spacerItem {
    return shift->{spacerItem};
}

sub okButton {
    return shift->{okButton};
}

sub cancelButton {
    return shift->{cancelButton};
}

sub spacerItem1 {
    return shift->{spacerItem1};
}


sub setupUi {
    my ( $class, $nicknameDialog ) = @_;
    my $self = bless {}, $class;
    if ( !defined $nicknameDialog->objectName() ) {
        $nicknameDialog->setObjectName( 'nicknameDialog' );
    }
    $nicknameDialog->resize( 396, 105 );
    my $sizePolicy = Qt::SizePolicy( 1, 1 );
    $self->{$sizePolicy} = $sizePolicy;
    $sizePolicy->setHorizontalStretch( 0 );
    $sizePolicy->setVerticalStretch( 0 );
    $sizePolicy->setHeightForWidth( $nicknameDialog->sizePolicy()->hasHeightForWidth() );
    $nicknameDialog->setSizePolicy( $sizePolicy );
    my $vboxLayout = Qt::VBoxLayout( $nicknameDialog );
    $self->{vboxLayout} = $vboxLayout;
    $vboxLayout->setSpacing( 6 );
    $vboxLayout->setMargin( 9 );
    $vboxLayout->setObjectName( 'vboxLayout' );
    my $vboxLayout1 = Qt::VBoxLayout(  );
    $self->{vboxLayout1} = $vboxLayout1;
    $vboxLayout1->setSpacing( 6 );
    $vboxLayout1->setMargin( 0 );
    $vboxLayout1->setObjectName( 'vboxLayout1' );
    my $label = Qt::Label( $nicknameDialog );
    $self->{label} = $label;
    $label->setObjectName( 'label' );
    $sizePolicy->setHeightForWidth( $label->sizePolicy()->hasHeightForWidth() );
    $label->setSizePolicy( $sizePolicy );

    $vboxLayout1->addWidget( $label );

    my $nickname = Qt::LineEdit( $nicknameDialog );
    $self->{nickname} = $nickname;
    $nickname->setObjectName( 'nickname' );

    $vboxLayout1->addWidget( $nickname );


    $vboxLayout->addLayout( $vboxLayout1 );

    my $hboxLayout = Qt::HBoxLayout(  );
    $self->{hboxLayout} = $hboxLayout;
    $hboxLayout->setSpacing( 6 );
    $hboxLayout->setMargin( 0 );
    $hboxLayout->setObjectName( 'hboxLayout' );
    my $spacerItem = Qt::SpacerItem( 131, 31, Qt::SizePolicy::Expanding(), Qt::SizePolicy::Minimum() );

    $hboxLayout->addItem( $spacerItem );

    my $okButton = Qt::PushButton( $nicknameDialog );
    $self->{okButton} = $okButton;
    $okButton->setObjectName( 'okButton' );

    $hboxLayout->addWidget( $okButton );

    my $cancelButton = Qt::PushButton( $nicknameDialog );
    $self->{cancelButton} = $cancelButton;
    $cancelButton->setObjectName( 'cancelButton' );

    $hboxLayout->addWidget( $cancelButton );

    my $spacerItem1 = Qt::SpacerItem( 40, 20, Qt::SizePolicy::Expanding(), Qt::SizePolicy::Minimum() );

    $hboxLayout->addItem( $spacerItem1 );


    $vboxLayout->addLayout( $hboxLayout );


    $self->retranslateUi( $nicknameDialog );
    Qt::Object->connect($okButton, SIGNAL 'clicked()' , $nicknameDialog, SLOT 'accept()' );
    Qt::Object->connect($cancelButton, SIGNAL 'clicked()' , $nicknameDialog, SLOT 'reject()' );

    Qt::MetaObject->connectSlotsByName( $nicknameDialog );
    return $self;
} # setupUi

sub setup_ui {
    my ( $nicknameDialog ) = @_;
    return setupUi( $nicknameDialog );
}

sub retranslateUi {
    my ( $self, $nicknameDialog ) = @_;
    $nicknameDialog->setWindowTitle( Qt::Application::translate( 'NicknameDialog', 'Set nickname', undef, Qt::Application::UnicodeUTF8() ) );
    $self->label()->setText( Qt::Application::translate( 'NicknameDialog', 'New nickname:', undef, Qt::Application::UnicodeUTF8() ) );
    $self->okButton()->setText( Qt::Application::translate( 'NicknameDialog', 'OK', undef, Qt::Application::UnicodeUTF8() ) );
    $self->cancelButton()->setText( Qt::Application::translate( 'NicknameDialog', 'Cancel', undef, Qt::Application::UnicodeUTF8() ) );
} # retranslateUi

sub retranslate_ui {
    my ( $nicknameDialog ) = @_;
    retranslateUi( $nicknameDialog );
}

1;