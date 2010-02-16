#!/usr/bin/perl

package NicknameDialog;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::Dialog );
use Ui_NicknameDialog;

sub cancelButton {
    return this->ui->cancelButton;
}

sub nickname {
    return this->ui->nickname;
}

sub ui {
    return this->{ui};
}

sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
    this->{ui} = Ui_NicknameDialog->setupUi(this);
}

package ChatMainWindow;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::MainWindow );
use Qt4::signals
    message => ['const QString &', 'const QString &'],
    action => ['const QString &', 'const QString &'];

use Qt4::slots
    messageSlot => ['const QString &', 'const QString &'],
    actionSlot => ['const QString &', 'const QString &'],
    textChangedSlot => ['const QString &'],
    sendClickedSlot => [],
    changeNickname => [],
    aboutQt => [],
    exiting => [];

use Ui_ChatMainWindow;
use NicknameDialog;

sub m_nickname() {
    return this->{m_nickname};
}

sub m_messages() {
    return this->{m_messages};
}

sub ui {
    return this->{ui};
}

use ChatAdaptor;
use ComTrolltechChatInterface;

sub NEW
{
    my ($class, $m_nickname) = @_;
    $class->SUPER::NEW();
    this->{m_nickname} = $m_nickname;

    this->{m_messages} = [];

    this->{ui} = Ui_ChatMainWindow->setupUi(this);
    this->ui->sendButton->setEnabled(0);

    this->connect(this->ui->messageLineEdit, SIGNAL 'textChanged(QString)',
            this, SLOT 'textChangedSlot(QString)');
    this->connect(this->ui->sendButton, SIGNAL 'clicked(bool)', this, SLOT 'sendClickedSlot()');
    this->connect(this->ui->actionChangeNickname, SIGNAL 'triggered(bool)', this, SLOT 'changeNickname()');
    this->connect(this->ui->actionAboutQt, SIGNAL 'triggered(bool)', this, SLOT 'aboutQt()');
    this->connect(qApp, SIGNAL 'lastWindowClosed()', this, SLOT 'exiting()');

    # add our D-Bus interface and connect to D-Bus
    ChatAdaptor(this);
    Qt4::DBusConnection::sessionBus()->registerObject('/', this);

    my $iface = ComTrolltechChatInterface('', '', Qt4::DBusConnection::sessionBus(), this);
    #connect(iface, SIGNAL 'message(Qt4::String,Qt4::String)', this, SLOT 'messageSlot(Qt4::String,Qt4::String)');
    Qt4::DBusConnection::sessionBus()->connect('', '', 'com.trolltech.chat', 'message', this, SLOT 'messageSlot(QString,QString)');
    this->connect($iface, SIGNAL 'action(QString,QString)', this, SLOT 'actionSlot(QString,QString)');

    my $dialog = NicknameDialog();
    $dialog->cancelButton->setVisible(0);
    $dialog->exec();
    this->{m_nickname} = $dialog->nickname->text();
    emit this->action(this->m_nickname, 'joins the chat');
}

sub rebuildHistory
{
    my $history = join "\n", @{this->m_messages};
    this->ui->chatHistory->setPlainText($history);
}

sub messageSlot
{
    my ($nickname, $text) = @_;
    my $msg = "<$nickname> $text";
    push @{this->m_messages}, $msg;

    if (scalar @{this->m_messages} > 100) {
        pop @{this->m_messages};
    }
    this->rebuildHistory();
}

sub actionSlot
{
    my ($nickname, $text) = @_;
    my $msg = "* $nickname $text";
    push @{this->m_messages}, $msg;

    if (scalar @{this->m_messages} > 100) {
        pop @{this->m_messages};
    }
    this->rebuildHistory();
}

sub textChangedSlot
{
    my ($newText) = @_;
    this->ui->sendButton->setEnabled($newText);
}

sub sendClickedSlot
{
    # This line is commented out in the source Qt example.
    #emit message(m_nickname, messageLineEdit->text());
    my $msg = Qt4::DBusMessage::createSignal('/', 'com.trolltech.chat', 'message');
    no warnings qw(void);
    $msg << Qt4::Variant(Qt4::String(this->m_nickname)) << Qt4::Variant(Qt4::String(this->ui->messageLineEdit->text()));
    use warnings;
    Qt4::DBusConnection::sessionBus()->send($msg);
    this->ui->messageLineEdit->setText('');
}

sub changeNickname
{
    my $dialog = NicknameDialog(this);
    if ($dialog->exec() == Qt4::Dialog::Accepted()) {
        my $old = this->m_nickname;
        this->{m_nickname} = $dialog->nickname->text();
        emit this->action($old, 'is now known as ' . this->m_nickname);
    }
}

sub aboutQt()
{
    Qt4::MessageBox::aboutQt(this);
}

sub exiting
{
    emit this->action(this->m_nickname, 'leaves the chat');
}

package main;

use strict;
use warnings;
use Qt4;
use ChatMainWindow;

sub main
{
    my $app = Qt4::Application( \@ARGV );

    if (!Qt4::DBusConnection::sessionBus()->isConnected()) {
        warn "Cannot connect to the D-Bus session bus.\n" .
             "Please check your system settings and try again.\n";
        return 1;
    }

    my $chat = ChatMainWindow();
    $chat->show();
    return $app->exec();
}

exit main();
