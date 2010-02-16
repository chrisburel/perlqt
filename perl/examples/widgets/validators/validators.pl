#!/usr/bin/perl

package ValidatorWidget;

use strict;
use warnings;

use Qt;
use Ui_ValidatorsForm;
use Qt::isa qw( Qt::Widget Ui_ValidatorsForm );
use Qt::slots
    updateValidator => [],
    updateDoubleValidator => [],
    _setLocale => ['const QLocale &'];

sub _setLocale {
    my( $l ) = @_;
    this->setLocale($l);
    this->updateValidator();
    this->updateDoubleValidator();
}

sub validator() {
    return this->{validator};
}

sub doubleValidator() {
    return this->{doubleValidator};
}

sub NEW {
    my ( $class, $parent ) = @_;
    $class->SUPER::NEW( $parent );
    $class->setupUi(this);

    my $localeSelector = this->{localeSelector};
    this->connect($localeSelector, SIGNAL 'localeSelected(QLocale)', this, SLOT '_setLocale(QLocale)');

    my $minVal = this->{minVal};
    my $maxVal = this->{maxVal};
    my $editor = this->{editor};
    my $ledWidget = this->{ledWidget};
    this->connect($minVal, SIGNAL 'editingFinished()', this, SLOT 'updateValidator()');
    this->connect($maxVal, SIGNAL 'editingFinished()', this, SLOT 'updateValidator()');
    this->connect($editor, SIGNAL 'editingFinished()', $ledWidget, SLOT 'flash()');

    my $doubleMaxVal = this->{doubleMaxVal};
    my $doubleMinVal = this->{doubleMinVal};
    my $doubleDecimals = this->{doubleDecimals};
    my $doubleFormat = this->{doubleFormat};
    my $doubleEditor = this->{doubleEditor};
    my $doubleLedWidget = this->{doubleLedWidget};
    this->connect($doubleMaxVal, SIGNAL 'editingFinished()', this, SLOT 'updateDoubleValidator()');
    this->connect($doubleMinVal, SIGNAL 'editingFinished()', this, SLOT 'updateDoubleValidator()');
    this->connect($doubleDecimals, SIGNAL 'valueChanged(int)', this, SLOT 'updateDoubleValidator()');
    this->connect($doubleFormat, SIGNAL 'activated(int)', this, SLOT 'updateDoubleValidator()');
    this->connect($doubleEditor, SIGNAL 'editingFinished()', $doubleLedWidget, SLOT 'flash()');

    this->{validator} = 0;
    this->{doubleValidator} = 0;
    this->updateValidator();
    this->updateDoubleValidator();
}

sub updateValidator {
    my $minVal = this->{minVal};
    my $maxVal = this->{maxVal};
    my $editor = this->{editor};
    my $v = Qt::IntValidator($minVal->value(), $maxVal->value(), this);
    $v->setLocale(this->locale());
    $editor->setValidator($v);
    #delete validator;
    this->{validator} = $v;
    my $validator = this->{validator};

    my $s = $editor->text();
    my $i = 0;
    if ($validator->validate($s, $i) == Qt::Validator::Invalid()) {
        $editor->clear();
    } else {
        $editor->setText($s);
    }
}

sub updateDoubleValidator {
    my $doubleMinVal = this->{doubleMinVal};
    my $doubleMaxVal = this->{doubleMaxVal};
    my $doubleDecimals = this->{doubleDecimals};
    my $doubleFormat = this->{doubleFormat};
    my $v = Qt::DoubleValidator($doubleMinVal->value(), $doubleMaxVal->value(),
                                $doubleDecimals->value(), this);
    #v->setNotation(static_cast<Qt::DoubleValidator::Notation>(doubleFormat->currentIndex()));
    $v->setNotation($doubleFormat->currentIndex());
    $v->setLocale(this->locale());
    my $doubleEditor = this->{doubleEditor};
    $doubleEditor->setValidator($v);
    this->{doubleValidator} = $v;
    my $doubleValidator = this->{doubleValidator};

    my $s = $doubleEditor->text();
    my $i = 0;
    if ($doubleValidator->validate($s, $i) == Qt::Validator::Invalid()) {
        $doubleEditor->clear();
    } else {
        $doubleEditor->setText($s);
    }
}

1;

package main;

use strict;
use warnings;

use Qt;
use ValidatorWidget;

sub main {
    my $app = Qt::Application( \@ARGV );

    my $w = ValidatorWidget();
    $w->show();

    return $app->exec();
}

exit main();
