package MainWindow;

use strict;
use warnings;
use QtCore4;
use KDEUi4;
use Qt4::isa qw( KDE::XmlGuiWindow );
use Qt4::GlobalSpace qw( i18n );

sub NEW
{
    my ( $class, $parent ) = @_;
    $class->SUPER::NEW( $parent );
    this->{textArea} = KDE::TextEdit();
    this->setCentralWidget(this->{textArea});

    this->setupActions();
}

sub setupActions
{
    my $clearAction = KDE::Action(this);
    $clearAction->setText(i18n('&Clear'));
    $clearAction->setIcon(KDE::Icon('document-new'));
    $clearAction->setShortcut(Qt4::KeySequence('Ctrl+W'));
    this->actionCollection()->addAction(Qt4::String('clear'), $clearAction);
    this->connect($clearAction, SIGNAL 'triggered(bool)',
            this->{textArea}, SLOT 'clear()');

    KDE::StandardAction::quit(kapp(), SLOT 'quit()',
            this->actionCollection());

    this->setupGUI(KDE::XmlGuiWindow::Default(), 'tutorial3ui.rc');
}

1;
