#!/usr/bin/perl

use strict;
use warnings;

use Qt4;
use SpinBoxDelegate;

# [0]
sub main {
    my $app = Qt4::Application( \@ARGV );

    my $model = Qt4::StandardItemModel(4, 2);
    my $tableView = Qt4::TableView();
    $tableView->setModel($model);

    my $delegate = SpinBoxDelegate();
    $tableView->setItemDelegate($delegate);
# [0]

# [1]
    for (my $row = 0; $row < 4; ++$row) {
        for (my $column = 0; $column < 2; ++$column) {
            my $index = $model->index($row, $column, Qt4::ModelIndex());
            $model->setData($index, Qt4::Variant(($row+1) * ($column+1)));
        }
# [1] //! [2]
    }
# [2]

# [3]
    $tableView->setWindowTitle(Qt4::Object::tr('Spin Box Delegate'));
    $tableView->show();
    return $app->exec();
}
# [3]

exit main();
