package Window;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::Widget );
use BorderLayout;

sub NEW
{
    my ($class) = @_;
    $class->SUPER::NEW();
    my $centralWidget = Qt4::TextBrowser();
    $centralWidget->setPlainText(this->tr('Central widget'));

    my $layout = BorderLayout();
    $layout->addWidget($centralWidget, BorderLayout::Center);
    $layout->addWidget(this->createLabel('North'), BorderLayout::North);
    $layout->addWidget(this->createLabel('West'), BorderLayout::West);
    $layout->addWidget(this->createLabel('East 1'), BorderLayout::East);
    $layout->addWidget(this->createLabel('East 2') , BorderLayout::East);
    $layout->addWidget(this->createLabel('South'), BorderLayout::South);
    this->setLayout($layout);

    this->setWindowTitle(this->tr('Border Layout'));
}

sub createLabel
{
    my ($text) = @_;
    my $label = Qt4::Label($text);
    $label->setFrameStyle(Qt4::Frame::Box() | Qt4::Frame::Raised());
    return $label;
}

1;
