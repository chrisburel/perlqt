package Sender;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::Dialog );
use Qt4::slots
    startBroadcasting => [],
    broadcastDatagram => [];

sub statusLabel() {
    return this->{statusLabel};
}

sub startButton() {
    return this->{startButton};
}

sub quitButton() {
    return this->{quitButton};
}

sub buttonBox() {
    return this->{buttonBox};
}

sub udpSocket() {
    return this->{udpSocket};
}

sub timer() {
    return this->{timer};
}

sub messageNo() {
    return this->{messageNo};
}

sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
    this->{statusLabel} = Qt4::Label(this->tr('Ready to broadcast datagrams on port 45454'));

    this->{startButton} = Qt4::PushButton(this->tr('&Start'));
    this->{quitButton} = Qt4::PushButton(this->tr('&Quit'));

    this->{buttonBox} = Qt4::DialogButtonBox();
    this->buttonBox->addButton(this->startButton, Qt4::DialogButtonBox::ActionRole());
    this->buttonBox->addButton(this->quitButton, Qt4::DialogButtonBox::RejectRole());

    this->{timer} = Qt4::Timer(this);
# [0]
    this->{udpSocket} = Qt4::UdpSocket(this);
# [0]
    this->{messageNo} = 1;

    this->connect(this->startButton, SIGNAL 'clicked()', this, SLOT 'startBroadcasting()');
    this->connect(this->quitButton, SIGNAL 'clicked()', this, SLOT 'close()');
    this->connect(this->timer, SIGNAL 'timeout()', this, SLOT 'broadcastDatagram()');

    my $mainLayout = Qt4::VBoxLayout();
    $mainLayout->addWidget(this->statusLabel);
    $mainLayout->addWidget(this->buttonBox);
    this->setLayout($mainLayout);

    this->setWindowTitle(this->tr('Broadcast Sender'));
}

sub startBroadcasting
{
    this->startButton->setEnabled(0);
    timer->start(1000);
}

sub broadcastDatagram
{
    this->statusLabel->setText(sprintf this->tr('Now broadcasting datagram %s'), this->messageNo);
# [1]
    my $datagram = Qt4::ByteArray('Broadcast message ' . this->messageNo);
    udpSocket->writeDatagram($datagram->data(), $datagram->size(),
                             Qt4::HostAddress(Qt4::HostAddress::Broadcast()), 45454);
# [1]
    ++this->{messageNo};
}

1;
