
=begin

** Form generated from reading ui file 'controller.ui'
**
** Created: Tue Dec 1 18:30:17 2009
**      by: Qt4 User Interface Compiler version 4.4.3
**
** WARNING! All changes made in this file will be lost when recompiling ui file!

=cut

package Ui_Controller;

use strict;
use warnings;
use utf8;
use Qt4;

sub gridLayout {
    return shift->{gridLayout};
}

sub label {
    return shift->{label};
}

sub decelerate {
    return shift->{decelerate};
}

sub accelerate {
    return shift->{accelerate};
}

sub right {
    return shift->{right};
}

sub left {
    return shift->{left};
}


sub setupUi {
    my ( $class, $controller ) = @_;
    my $self = bless {}, $class;
    if ( !defined $controller->objectName() ) {
        $controller->setObjectName( 'controller' );
    }
    $controller->resize( 255, 111 );
    my $gridLayout = Qt4::GridLayout( $controller );
    $self->{gridLayout} = $gridLayout;
    $gridLayout->setSpacing( 6 );
    $gridLayout->setMargin( 9 );
    $gridLayout->setObjectName( 'gridLayout' );
    my $label = Qt4::Label( $controller );
    $self->{label} = $label;
    $label->setObjectName( 'label' );
    $label->setAlignment( Qt4::AlignCenter() );

    $gridLayout->addWidget( $label, 1, 1, 1, 1 );

    my $decelerate = Qt4::PushButton( $controller );
    $self->{decelerate} = $decelerate;
    $decelerate->setObjectName( 'decelerate' );

    $gridLayout->addWidget( $decelerate, 2, 1, 1, 1 );

    my $accelerate = Qt4::PushButton( $controller );
    $self->{accelerate} = $accelerate;
    $accelerate->setObjectName( 'accelerate' );

    $gridLayout->addWidget( $accelerate, 0, 1, 1, 1 );

    my $right = Qt4::PushButton( $controller );
    $self->{right} = $right;
    $right->setObjectName( 'right' );

    $gridLayout->addWidget( $right, 1, 2, 1, 1 );

    my $left = Qt4::PushButton( $controller );
    $self->{left} = $left;
    $left->setObjectName( 'left' );

    $gridLayout->addWidget( $left, 1, 0, 1, 1 );


    $self->retranslateUi( $controller );

    Qt4::MetaObject->connectSlotsByName( $controller );
    return $self;
} # setupUi

sub setup_ui {
    my ( $controller ) = @_;
    return setupUi( $controller );
}

sub retranslateUi {
    my ( $self, $controller ) = @_;
    $controller->setWindowTitle( Qt4::Application::translate( 'Controller', 'Controller', undef, Qt4::Application::UnicodeUTF8() ) );
    $self->label()->setText( Qt4::Application::translate( 'Controller', 'Controller', undef, Qt4::Application::UnicodeUTF8() ) );
    $self->decelerate()->setText( Qt4::Application::translate( 'Controller', 'Decelerate', undef, Qt4::Application::UnicodeUTF8() ) );
    $self->accelerate()->setText( Qt4::Application::translate( 'Controller', 'Accelerate', undef, Qt4::Application::UnicodeUTF8() ) );
    $self->right()->setText( Qt4::Application::translate( 'Controller', 'Right', undef, Qt4::Application::UnicodeUTF8() ) );
    $self->left()->setText( Qt4::Application::translate( 'Controller', 'Left', undef, Qt4::Application::UnicodeUTF8() ) );
} # retranslateUi

sub retranslate_ui {
    my ( $controller ) = @_;
    retranslateUi( $controller );
}

1;