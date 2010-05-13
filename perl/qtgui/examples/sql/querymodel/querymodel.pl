#!/usr/bin/perl

use strict;
use warnings;
use Qt4;

use lib '../';
use Connection;
use CustomSqlModel;
use EditableSqlModel;

sub initializeModel
{
    my ($model) = @_;
    $model->setQuery('select * from person');
    $model->setHeaderData(0, Qt4::Horizontal(), Qt4::Variant(Qt4::String(Qt4::Object::tr('ID'))));
    $model->setHeaderData(1, Qt4::Horizontal(), Qt4::Variant(Qt4::String(Qt4::Object::tr('First name'))));
    $model->setHeaderData(2, Qt4::Horizontal(), Qt4::Variant(Qt4::String(Qt4::Object::tr('Last name'))));
}

my $offset = 0;

sub createView
{
    my ($title, $model) = @_;

    my $view = Qt4::TableView();
    $view->setModel($model);
    $view->setWindowTitle($title);
    $view->move(100 + $offset, 100 + $offset);
    $offset += 20;
    $view->show();
}

sub main
{
    my $app = Qt4::Application(\@ARGV);
    if (!Connection::createConnection()){
        return 1;
    }

    my $plainModel = Qt4::SqlQueryModel();
    my $editableModel = EditableSqlModel();
    my $customModel = CustomSqlModel();

    initializeModel($plainModel);
    initializeModel($editableModel);
    initializeModel($customModel);

    createView(Qt4::Object::tr('Plain Query Model'), $plainModel);
    createView(Qt4::Object::tr('Editable Query Model'), $editableModel);
    createView(Qt4::Object::tr('Custom Query Model'), $customModel);

    return $app->exec();
}

exit main();
