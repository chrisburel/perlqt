#!/usr/bin/perl

use strict;
use warnings;

use Qt;

my $app = Qt::Application( \@ARGV );

my $model = Qt::DirModel();
my $tree = Qt::TreeView();
$tree->setModel($model);

# Demonstrating look and feel features
$tree->setAnimated(0);
$tree->setIndentation(20);
$tree->setSortingEnabled(1);

$tree->setWindowTitle(Qt::Object::tr('Dir View'));
$tree->resize(640, 480);
$tree->show();

exit $app->exec();
