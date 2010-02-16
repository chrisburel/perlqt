
=begin

** Form generated from reading ui file 'controller.ui'
**
** Created: Wed Sep 23 17:12:01 2009
**      by: Qt User Interface Compiler version 4.4.3
**
** WARNING! All changes made in this file will be lost when recompiling ui file!

=cut

package Ui_Controller;

use strict;
use warnings;
use utf8;
use Qt;

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
    my $gridLayout = Qt::GridLayout( $controller );
    $self->{gridLayout} = $gridLayout;
    $gridLayout->setSpacing( 6 );
    $gridLayout->setMargin( 9 );
    $gridLayout->setObjectName( 'gridLayout' );
    my $label = Qt::Label( $controller );
    $self->{label} = $label;
    $label->setObjectName( 'label' );
    $label->setAlignment( Qt::AlignCenter() );

    $gridLayout->addWidget( $label, 1, 1, 1, 1 );

    my $decelerate = Qt::PushButton( $controller );
    $self->{decelerate} = $decelerate;
    $decelerate->setObjectName( 'decelerate' );

    $gridLayout->addWidget( $decelerate, 2, 1, 1, 1 );

    my $accelerate = Qt::PushButton( $controller );
    $self->{accelerate} = $accelerate;
    $accelerate->setObjectName( 'accelerate' );

    $gridLayout->addWidget( $accelerate, 0, 1, 1, 1 );

    my $right = Qt::PushButton( $controller );
    $self->{right} = $right;
    $right->setObjectName( 'right' );

    $gridLayout->addWidget( $right, 1, 2, 1, 1 );

    my $left = Qt::PushButton( $controller );
    $self->{left} = $left;
    $left->setObjectName( 'left' );

    $gridLayout->addWidget( $left, 1, 0, 1, 1 );


    $self->retranslateUi( $controller );

    Qt::MetaObject->connectSlotsByName( $controller );
    return $self;
} # setupUi

sub setup_ui {
    my ( $controller ) = @_;
    return setupUi( $controller );
}

sub retranslateUi {
    my ( $self, $controller ) = @_;
    $controller->setWindowTitle( Qt::Application::translate( 'Controller', 'Controller', undef, Qt::Application::UnicodeUTF8() ) );
    $self->label()->setText( Qt::Application::translate( 'Controller', 'Controller', undef, Qt::Application::UnicodeUTF8() ) );
    $self->decelerate()->setText( Qt::Application::translate( 'Controller', 'Decelerate', undef, Qt::Application::UnicodeUTF8() ) );
    $self->accelerate()->setText( Qt::Application::translate( 'Controller', 'Accelerate', undef, Qt::Application::UnicodeUTF8() ) );
    $self->right()->setText( Qt::Application::translate( 'Controller', 'Right', undef, Qt::Application::UnicodeUTF8() ) );
    $self->left()->setText( Qt::Application::translate( 'Controller', 'Left', undef, Qt::Application::UnicodeUTF8() ) );
} # retranslateUi

sub retranslate_ui {
    my ( $controller ) = @_;
    retranslateUi( $controller );
}

1;