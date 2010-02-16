#!/usr/bin/perl

use strict;
use warnings;

use Qt4;

my $app = Qt4::Application( \@ARGV );

my $model = Qt4::DirModel();
my $tree = Qt4::TreeView();
$tree->setModel($model);

# Demonstrating look and feel features
$tree->setAnimated(0);
$tree->setIndentation(20);
$tree->setSortingEnabled(1);

$tree->setWindowTitle(Qt4::Object::tr('Dir View'));
$tree->resize(640, 480);
$tree->show();

exit $app->exec();
