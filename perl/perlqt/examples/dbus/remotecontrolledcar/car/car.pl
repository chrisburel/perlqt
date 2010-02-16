#!/usr/bin/perl

use strict;
use warnings;
use Qt4;
use Car;
use CarAdaptor;

sub main
{
    my $app = Qt4::Application(\@ARGV);

    my $scene = Qt4::GraphicsScene();
    $scene->setSceneRect(-500, -500, 1000, 1000);
    $scene->setItemIndexMethod(Qt4::GraphicsScene::NoIndex());

    my $car = Car();
    $scene->addItem($car);

    my $view = Qt4::GraphicsView($scene);
    $view->setRenderHint(Qt4::Painter::Antialiasing());
    $view->setBackgroundBrush(Qt4::darkGray());
    $view->setWindowTitle(qApp->translate('Qt4::GraphicsView', 'Qt DBus Controlled Car'));
    $view->resize(400, 300);
    $view->show();

    my $adaptorParent = Qt4::Object();
    my $adaptor = CarAdaptor($adaptorParent, $car);
    my $connection = Qt4::DBusConnection::sessionBus();
    $connection->registerObject('/Car', $adaptorParent);
    $connection->registerService('com.trolltech.CarExample');

    return $app->exec();
}

exit main();
