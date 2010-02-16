package Receiver;

use strict;
use warnings;
use Qt;
use Qt::isa qw( Qt::Dialog );
use Qt::slots
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
    this->{statusLabel} = Qt::Label(this->tr('Listening for broadcasted messages'));
    this->{quitButton} = Qt::PushButton(this->tr('&Quit'));

# [0]
    this->{udpSocket} = Qt::UdpSocket(this);
    this->udpSocket->bind(45454);
# [0]

# [1]
    this->connect(this->udpSocket, SIGNAL 'readyRead()',
            this, SLOT 'processPendingDatagrams()');
# [1]
    this->connect(this->quitButton, SIGNAL 'clicked()', this, SLOT 'close()');

    my $buttonLayout = Qt::HBoxLayout();
    $buttonLayout->addStretch(1);
    $buttonLayout->addWidget(this->quitButton);
    $buttonLayout->addStretch(1);

    my $mainLayout = Qt::VBoxLayout();
    $mainLayout->addWidget(this->statusLabel);
    $mainLayout->addLayout($buttonLayout);
    this->setLayout($mainLayout);

    this->setWindowTitle(this->tr('Broadcast Receiver'));
}

sub processPendingDatagrams
{
# [2]
    while (this->udpSocket->hasPendingDatagrams()) {
        $DB::single=1;
        my $datagram = Qt::ByteArray();
        $datagram->resize(this->udpSocket->pendingDatagramSize());
        this->udpSocket->readDatagram($datagram->data(), $datagram->size());
        this->statusLabel->setText(sprintf this->tr('Received datagram: \'%s\''),
                             $datagram->data());
    }
# [2]
}

1;
