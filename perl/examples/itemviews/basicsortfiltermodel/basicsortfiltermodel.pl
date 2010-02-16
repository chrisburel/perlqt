#!/usr/bin/perl

use strict;
use warnings;

use Qt4;
use Window;

sub addMail {
    my ( $model, $subject, $sender, $date) = @_;
    $model->insertRow(0);
    $model->setData($model->index(0, 0), Qt4::Variant($subject));
    $model->setData($model->index(0, 1), Qt4::Variant($sender));
    $model->setData($model->index(0, 2), Qt4::Variant($date));
}

sub createMailModel {
    my ( $parent ) = @_;
    my $model = Qt4::StandardItemModel(0, 3, $parent);

    $model->setHeaderData(0, Qt4::Horizontal(), Qt4::Variant(Qt4::Object::tr('Subject)')));
    $model->setHeaderData(1, Qt4::Horizontal(), Qt4::Variant(Qt4::Object::tr('Sender')));
    $model->setHeaderData(2, Qt4::Horizontal(), Qt4::Variant(Qt4::Object::tr('Date')));

    addMail($model, 'Happy New Year!', 'Grace K. <grace@software-inc.com>',
            Qt4::DateTime(Qt4::Date(2006, 12, 31), Qt4::Time(17, 03)));
    addMail($model, 'Radically new concept', 'Grace K. <grace@software-inc.com>',
            Qt4::DateTime(Qt4::Date(2006, 12, 22), Qt4::Time(9, 44)));
    addMail($model, 'Accounts', 'pascale@nospam.com',
            Qt4::DateTime(Qt4::Date(2006, 12, 31), Qt4::Time(12, 50)));
    addMail($model, 'Expenses', 'Joe Bloggs <joe@bloggs.com>',
            Qt4::DateTime(Qt4::Date(2006, 12, 25), Qt4::Time(11, 39)));
    addMail($model, 'Re: Expenses', 'Andy <andy@nospam.com>',
            Qt4::DateTime(Qt4::Date(2007, 01, 02), Qt4::Time(16, 05)));
    addMail($model, 'Re: Accounts', 'Joe Bloggs <joe@bloggs.com>',
            Qt4::DateTime(Qt4::Date(2007, 01, 03), Qt4::Time(14, 18)));
    addMail($model, 'Re: Accounts', 'Andy <andy@nospam.com>',
            Qt4::DateTime(Qt4::Date(2007, 01, 03), Qt4::Time(14, 26)));
    addMail($model, 'Sports', 'Linda Smith <linda.smith@nospam.com>',
            Qt4::DateTime(Qt4::Date(2007, 01, 05), Qt4::Time(11, 33)));
    addMail($model, 'AW: Sports', 'Rolf Newschweinstein <rolfn@nospam.com>',
            Qt4::DateTime(Qt4::Date(2007, 01, 05), Qt4::Time(12, 00)));
    addMail($model, 'RE: Sports', 'Petra Schmidt <petras@nospam.com>',
            Qt4::DateTime(Qt4::Date(2007, 01, 05), Qt4::Time(12, 01)));

    return $model;
}

sub main {
    my $app = Qt4::Application( \@ARGV );
    my $window = Window();
    $window->setSourceModel(createMailModel($window));
    $window->show();
    exit $app->exec();
}

main();
