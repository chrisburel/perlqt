#!/usr/bin/perl

use strict;
use warnings;
use Qt4;

use lib '../';
use Connection;

sub initializeModel
{
# [0]
    my ($model) = @_;
    $model->setTable('employee');
# [0]

    $model->setEditStrategy(Qt4::SqlTableModel::OnManualSubmit());
# [1]
    $model->setRelation(2, Qt4::SqlRelation('city', 'id', 'name'));
# [1] //! [2]
    $model->setRelation(3, Qt4::SqlRelation('country', 'id', 'name'));
# [2]

# [3]
    $model->setHeaderData(0, Qt4::Horizontal(), Qt4::Variant(Qt4::String(Qt4::Object::tr('ID'))));
    $model->setHeaderData(1, Qt4::Horizontal(), Qt4::Variant(Qt4::String(Qt4::Object::tr('Name'))));
    $model->setHeaderData(2, Qt4::Horizontal(), Qt4::Variant(Qt4::String(Qt4::Object::tr('City'))));
    $model->setHeaderData(3, Qt4::Horizontal(), Qt4::Variant(Qt4::String(Qt4::Object::tr('Country'))));
# [3]

    $model->select();
}

sub createView
{
# [4]
    my ($title, $model) = @_;
    my $view = Qt4::TableView();
    $view->setModel($model);
    $view->setItemDelegate(Qt4::SqlRelationalDelegate($view));
# [4]
    $view->setWindowTitle($title);
    return $view;
}

sub createRelationalTables
{
    my $query = Qt4::SqlQuery();
    $query->exec('create table employee(id int primary key, name varchar(20), city int, country int)');
    $query->exec('insert into employee values(1, \'Espen\', 5000, 47)');
    $query->exec('insert into employee values(2, \'Harald\', 80000, 49)');
    $query->exec('insert into employee values(3, \'Sam\', 100, 1)');

    $query->exec('create table city(id int, name varchar(20))');
    $query->exec('insert into city values(100, \'San Jose\')');
    $query->exec('insert into city values(5000, \'Oslo\')');
    $query->exec('insert into city values(80000, \'Munich\')');

    $query->exec('create table country(id int, name varchar(20))');
    $query->exec('insert into country values(1, \'USA\')');
    $query->exec('insert into country values(47, \'Norway\')');
    $query->exec('insert into country values(49, \'Germany\')');
}

sub main
{
    my $app = Qt4::Application(\@ARGV);
    if (!Connection::createConnection()) {
        return 1;
    }
    createRelationalTables();

    my $model = Qt4::SqlRelationalTableModel();

    initializeModel($model);

    my $view = createView(Qt4::Object::tr('Relational Table Model'), $model);
    $view->show();

    return $app->exec();
}

exit main();
