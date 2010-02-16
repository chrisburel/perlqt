#!/usr/local/bin/perl -w

use strict;
use warnings;
use blib;

package MyWidget;

use Qt;
use Qt::isa qw(Qt::QWidget);
use CannonField;
use LCDRange;

my @widgets;

sub NEW {
    shift->SUPER::NEW(@_);

    my $quit = Qt::QPushButton("Quit");
    $quit->setFont(Qt::QFont("Times", 18, Qt::QFont::Bold()));

    this->connect($quit, SIGNAL "clicked()", Qt::qapp(), SLOT "quit()");

    my $angle = LCDRange();
    $angle->setRange(5, 70);

    my $cannonField = CannonField();

    this->connect($angle, SIGNAL 'valueChanged(int)',
                  $cannonField, SLOT 'setAngle(int)');
    this->connect($cannonField, SIGNAL 'angleChanged(int)',
                  $angle, SLOT 'setValue(int)');

    my $gridLayout = Qt::QGridLayout();
    $gridLayout->addWidget($quit, 0, 0);
    $gridLayout->addWidget($angle, 1, 0);
    $gridLayout->addWidget($cannonField, 1, 1, 2, 1);
    $gridLayout->setColumnStretch(1, 10);
    this->setLayout($gridLayout);

    $angle->setValue(60);
    $angle->setFocus();

    push @widgets, $angle;
    push @widgets, $cannonField;
}

1;

package main;

use Qt;
use MyWidget;
#use Qt::debug qw(all);

sub dumpMetaMethods {
    my ( $meta ) = @_;

    print "Methods for ".$meta->className().":\n";
    foreach my $index ( 0..$meta->methodCount()-1 ) {
        my $metaMethod = $meta->method($index);
        print $metaMethod->signature() . "\n";
    }
    print "\n";
}

sub main {
    my $widget = MyWidget();
    $widget->setGeometry(100, 100, 500, 355);
    $widget->show();

    #dumpMetaMethods(Qt::_internal::getMetaObject('LCDRange'));
    #dumpMetaMethods(Qt::_internal::getMetaObject('CannonField'));

    return Qt::qapp()->exec();
} 

main();
