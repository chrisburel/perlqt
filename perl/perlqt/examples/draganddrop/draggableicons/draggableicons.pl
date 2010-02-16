#!/usr/bin/perl

use strict;
use warnings;

use Qt4;

use DragWidget;

sub main {
    my $app = Qt4::Application( \@ARGV );

    my $mainWidget = Qt4::Widget();
    my $horizontalLayout = Qt4::HBoxLayout();
    my $drag1=DragWidget();
    my $drag2=DragWidget();
    $horizontalLayout->addWidget($drag1);
    $horizontalLayout->addWidget($drag2);

    $mainWidget->setLayout($horizontalLayout);
    $mainWidget->setWindowTitle(Qt4::Object::tr('Draggable Icons'));
    $mainWidget->show();

    exit $app->exec();
}

main();
