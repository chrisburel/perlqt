
=begin

** Form generated from reading ui file 'chatmainwindow.ui'
**
** Created: Tue Sep 22 18:41:05 2009
**      by: Qt User Interface Compiler version 4.4.3
**
** WARNING! All changes made in this file will be lost when recompiling ui file!

=cut

package Ui_ChatMainWindow;

use strict;
use warnings;
use utf8;
use Qt;

sub actionQuit {
    return shift->{actionQuit};
}

sub actionAboutQt {
    return shift->{actionAboutQt};
}

sub actionChangeNickname {
    return shift->{actionChangeNickname};
}

sub centralwidget {
    return shift->{centralwidget};
}

sub hboxLayout {
    return shift->{hboxLayout};
}

sub vboxLayout {
    return shift->{vboxLayout};
}

sub chatHistory {
    return shift->{chatHistory};
}

sub hboxLayout1 {
    return shift->{hboxLayout1};
}

sub label {
    return shift->{label};
}

sub messageLineEdit {
    return shift->{messageLineEdit};
}

sub sendButton {
    return shift->{sendButton};
}

sub menubar {
    return shift->{menubar};
}

sub menuQuit {
    return shift->{menuQuit};
}

sub menuFile {
    return shift->{menuFile};
}

sub statusbar {
    return shift->{statusbar};
}


sub setupUi {
    my ( $class, $chatMainWindow ) = @_;
    my $self = bless {}, $class;
    if ( !defined $chatMainWindow->objectName() ) {
        $chatMainWindow->setObjectName( 'chatMainWindow' );
    }
    $chatMainWindow->resize( 800, 600 );
    my $actionQuit = Qt::Action($chatMainWindow);
    $self->{actionQuit} = $actionQuit;
    $actionQuit->setObjectName( 'actionQuit' );
    my $actionAboutQt = Qt::Action($chatMainWindow);
    $self->{actionAboutQt} = $actionAboutQt;
    $actionAboutQt->setObjectName( 'actionAboutQt' );
    my $actionChangeNickname = Qt::Action($chatMainWindow);
    $self->{actionChangeNickname} = $actionChangeNickname;
    $actionChangeNickname->setObjectName( 'actionChangeNickname' );
    my $centralwidget = Qt::Widget( $chatMainWindow );
    $self->{centralwidget} = $centralwidget;
    $centralwidget->setObjectName( 'centralwidget' );
    my $hboxLayout = Qt::HBoxLayout( $centralwidget );
    $self->{hboxLayout} = $hboxLayout;
    $hboxLayout->setSpacing( 6 );
    $hboxLayout->setMargin( 9 );
    $hboxLayout->setObjectName( 'hboxLayout' );
    my $vboxLayout = Qt::VBoxLayout(  );
    $self->{vboxLayout} = $vboxLayout;
    $vboxLayout->setSpacing( 6 );
    $vboxLayout->setMargin( 0 );
    $vboxLayout->setObjectName( 'vboxLayout' );
    my $chatHistory = Qt::TextBrowser( $centralwidget );
    $self->{chatHistory} = $chatHistory;
    $chatHistory->setObjectName( 'chatHistory' );
    $chatHistory->setAcceptDrops( 0 );
    $chatHistory->setAcceptRichText( 1 );

    $vboxLayout->addWidget( $chatHistory );

    my $hboxLayout1 = Qt::HBoxLayout(  );
    $self->{hboxLayout1} = $hboxLayout1;
    $hboxLayout1->setSpacing( 6 );
    $hboxLayout1->setMargin( 0 );
    $hboxLayout1->setObjectName( 'hboxLayout1' );
    my $label = Qt::Label( $centralwidget );
    $self->{label} = $label;
    $label->setObjectName( 'label' );

    $hboxLayout1->addWidget( $label );

    my $messageLineEdit = Qt::LineEdit( $centralwidget );
    $self->{messageLineEdit} = $messageLineEdit;
    $messageLineEdit->setObjectName( 'messageLineEdit' );

    $hboxLayout1->addWidget( $messageLineEdit );

    my $sendButton = Qt::PushButton( $centralwidget );
    $self->{sendButton} = $sendButton;
    $sendButton->setObjectName( 'sendButton' );
    my $sizePolicy = Qt::SizePolicy( 1, 0 );
    $self->{$sizePolicy} = $sizePolicy;
    $sizePolicy->setHorizontalStretch( 0 );
    $sizePolicy->setVerticalStretch( 0 );
    $sizePolicy->setHeightForWidth( $sendButton->sizePolicy()->hasHeightForWidth() );
    $sendButton->setSizePolicy( $sizePolicy );

    $hboxLayout1->addWidget( $sendButton );


    $vboxLayout->addLayout( $hboxLayout1 );


    $hboxLayout->addLayout( $vboxLayout );

    $chatMainWindow->setCentralWidget( $centralwidget );
    my $menubar = Qt::MenuBar( $chatMainWindow );
    $self->{menubar} = $menubar;
    $menubar->setObjectName( 'menubar' );
    $menubar->setGeometry( Qt::Rect(0, 0, 800, 31) );
    my $menuQuit = Qt::Menu( $menubar );
    $self->{menuQuit} = $menuQuit;
    $menuQuit->setObjectName( 'menuQuit' );
    my $menuFile = Qt::Menu( $menubar );
    $self->{menuFile} = $menuFile;
    $menuFile->setObjectName( 'menuFile' );
    $chatMainWindow->setMenuBar( $menubar );
    my $statusbar = Qt::StatusBar( $chatMainWindow );
    $self->{statusbar} = $statusbar;
    $statusbar->setObjectName( 'statusbar' );
    $chatMainWindow->setStatusBar( $statusbar );

    $menubar->addAction( $menuFile->menuAction() );
    $menubar->addAction( $menuQuit->menuAction() );
    $menuQuit->addAction( $actionAboutQt );
    $menuFile->addAction( $actionChangeNickname );
    $menuFile->addSeparator();
    $menuFile->addAction( $actionQuit );

    $self->retranslateUi( $chatMainWindow );
    Qt::Object->connect($messageLineEdit, SIGNAL 'returnPressed()' , $sendButton, SLOT 'animateClick()' );
    Qt::Object->connect($actionQuit, SIGNAL 'triggered(bool)' , $chatMainWindow, SLOT 'close()' );

    Qt::MetaObject->connectSlotsByName( $chatMainWindow );
    return $self;
} # setupUi

sub setup_ui {
    my ( $chatMainWindow ) = @_;
    return setupUi( $chatMainWindow );
}

sub retranslateUi {
    my ( $self, $chatMainWindow ) = @_;
    $chatMainWindow->setWindowTitle( Qt::Application::translate( 'ChatMainWindow', 'QtDBus Chat', undef, Qt::Application::UnicodeUTF8() ) );
    $self->actionQuit()->setText( Qt::Application::translate( 'ChatMainWindow', 'Quit', undef, Qt::Application::UnicodeUTF8() ) );
    $self->actionQuit()->setShortcut( Qt::Application::translate( 'ChatMainWindow', 'Ctrl+Q', undef, Qt::Application::UnicodeUTF8() ) );
    $self->actionAboutQt()->setText( Qt::Application::translate( 'ChatMainWindow', 'About Qt...', undef, Qt::Application::UnicodeUTF8() ) );
    $self->actionChangeNickname()->setText( Qt::Application::translate( 'ChatMainWindow', 'Change nickname...', undef, Qt::Application::UnicodeUTF8() ) );
    $self->actionChangeNickname()->setShortcut( Qt::Application::translate( 'ChatMainWindow', 'Ctrl+N', undef, Qt::Application::UnicodeUTF8() ) );
    $self->chatHistory()->setToolTip( Qt::Application::translate( 'ChatMainWindow', 'Messages sent and received from other users', undef, Qt::Application::UnicodeUTF8() ) );
    $self->label()->setText( Qt::Application::translate( 'ChatMainWindow', 'Message:', undef, Qt::Application::UnicodeUTF8() ) );
    $self->sendButton()->setToolTip( Qt::Application::translate( 'ChatMainWindow', 'Sends a message to other people', undef, Qt::Application::UnicodeUTF8() ) );
    $self->sendButton()->setWhatsThis( '' );
    $self->sendButton()->setText( Qt::Application::translate( 'ChatMainWindow', 'Send', undef, Qt::Application::UnicodeUTF8() ) );
    $self->menuQuit()->setTitle( Qt::Application::translate( 'ChatMainWindow', 'Help', undef, Qt::Application::UnicodeUTF8() ) );
    $self->menuFile()->setTitle( Qt::Application::translate( 'ChatMainWindow', 'File', undef, Qt::Application::UnicodeUTF8() ) );
} # retranslateUi

sub retranslate_ui {
    my ( $chatMainWindow ) = @_;
    retranslateUi( $chatMainWindow );
}

1;