package SourceWidget;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Widget );

#[0]
use Qt4::slots
    createData => ['QString'],
    startDrag => [];
#[0]

use MimeData;

sub NEW {
    shift->SUPER::NEW();
    my $imageFile = Qt4::File('images/example.svg');
    $imageFile->open(Qt4::IODevice::ReadOnly());
    my $imageData = $imageFile->readAll();
    this->{imageData} = $imageData;
    $imageFile->close();

    my $imageArea = Qt4::ScrollArea();
    my $imageLabel = Qt4::SvgWidget();
    this->{imageLabel} = $imageLabel;
    $imageLabel->renderer()->load($imageData);
    $imageArea->setWidget($imageLabel);
    #imageLabel->setMinimumSize(imageLabel->renderer()->viewBox()->size());

    my $instructTopLabel = Qt4::Label(this->tr('This is an SVG drawing:'));
    my $instructBottomLabel = Qt4::Label(
        this->tr('Drag the icon to copy the drawing as a PNG file:'));
    my $dragIcon = Qt4::PushButton(this->tr('Export'));
    $dragIcon->setIcon(Qt4::Icon('images/drag.png'));

    this->connect($dragIcon, SIGNAL 'pressed()', this, SLOT 'startDrag()');

    my $layout = Qt4::GridLayout();
    $layout->addWidget($instructTopLabel, 0, 0, 1, 2);
    $layout->addWidget($imageArea, 1, 0, 2, 2);
    $layout->addWidget($instructBottomLabel, 3, 0);
    $layout->addWidget($dragIcon, 3, 1);
    this->setLayout($layout);
    this->setWindowTitle(this->tr('Delayed Encoding'));
}

#[1]
sub createData {
    my ($mimeType) = @_;
    if ($mimeType ne 'image/png') {
        return;
    }

    my $imageLabel = this->{imageLabel};
    my $image = Qt4::Image($imageLabel->size(), Qt4::Image::Format_RGB32());
    my $painter = Qt4::Painter();
    $painter->begin($image);
    $imageLabel->renderer()->render($painter);
    $painter->end();

    my $data = Qt4::ByteArray();
    my $buffer = Qt4::Buffer($data);
    $buffer->open(Qt4::IODevice::WriteOnly());
    $image->save($buffer, 'PNG');
    $buffer->close();

    my $mimeData = this->{mimeData};
    $mimeData->setData('image/png', $data);
}
#[1]

#[0]
sub startDrag {
    my $mimeData = MimeData();
    this->{mimeData} = $mimeData;

    this->connect($mimeData, SIGNAL 'dataRequested(QString)',
            this, SLOT 'createData(QString)', Qt4::DirectConnection());

    my $drag = Qt4::Drag(this);
    $drag->setMimeData($mimeData);
    $drag->setPixmap(Qt4::Pixmap('images/drag.png'));

    $drag->exec(Qt4::CopyAction());
}
#[0]

1;
