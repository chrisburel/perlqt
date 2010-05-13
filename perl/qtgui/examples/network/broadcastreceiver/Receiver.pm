package Receiver;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::Dialog );
use Qt4::slots
    processPendingDatagrams => [];

sub statusLabel() {
    return this->{statusLabel};
}

sub quitButton() {
    return this->{quitButton};
}

sub udpSocket() {
    return this->{udpSocket};
}

sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
    this->{statusLabel} = Qt4::Label(this->tr('Listening for broadcasted messages'));
    this->{quitButton} = Qt4::PushButton(this->tr('&Quit'));

# [0]
    this->{udpSocket} = Qt4::UdpSocket(this);
    this->udpSocket->bind(45454);
# [0]

# [1]
    this->connect(this->udpSocket, SIGNAL 'readyRead()',
            this, SLOT 'processPendingDatagrams()');
# [1]
    this->connect(this->quitButton, SIGNAL 'clicked()', this, SLOT 'close()');

    my $buttonLayout = Qt4::HBoxLayout();
    $buttonLayout->addStretch(1);
    $buttonLayout->addWidget(this->quitButton);
    $buttonLayout->addStretch(1);

    my $mainLayout = Qt4::VBoxLayout();
    $mainLayout->addWidget(this->statusLabel);
    $mainLayout->addLayout($buttonLayout);
    this->setLayout($mainLayout);

    this->setWindowTitle(this->tr('Broadcast Receiver'));
}

sub processPendingDatagrams
{
# [2]
    while (this->udpSocket->hasPendingDatagrams()) {
        my $datagram = Qt4::ByteArray();
        $datagram->resize(this->udpSocket->pendingDatagramSize());
        this->udpSocket->readDatagram($datagram->data(), $datagram->size());
        this->statusLabel->setText(sprintf this->tr('Received datagram: \'%s\''),
                             $datagram->data());
    }
# [2]
}

1;
