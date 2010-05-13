package StyleSheetEditor;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::Dialog );

use Ui_StyleSheetEditor;

use Qt4::slots
    on_styleCombo_activated => ['QString'],
    on_styleSheetCombo_activated => ['QString'],
    on_styleTextEdit_textChanged => [],
    on_applyButton_clicked => [];

sub NEW {
    my ( $class, $parent ) = @_;
    $class->SUPER::NEW( $parent );
    my $ui = Ui_StyleSheetEditor->setupUi(this);
    this->{ui} = $ui;

    my $regExp = Qt4::RegExp("Q(.*)Style");
    my $defaultStyle = Qt4::Application::style()->metaObject()->className();

    if ($defaultStyle eq 'Qt4::MacStyle') {
        $defaultStyle = 'Macintosh (Aqua)';
    }
    elsif ($regExp->exactMatch($defaultStyle)) {
        $defaultStyle = $regExp->cap(1);
    }

    $ui->styleCombo()->addItems(Qt4::StyleFactory::keys());
    $ui->styleCombo()->setCurrentIndex($ui->styleCombo->findText($defaultStyle));
    $ui->styleSheetCombo()->setCurrentIndex($ui->styleSheetCombo->findText('Coffee'));
    loadStyleSheet('Coffee');
}

sub on_styleCombo_activated {
    my ($styleName) = @_;
    qApp->setStyle($styleName);
    this->{ui}->applyButton()->setEnabled(0);
}

sub on_styleSheetCombo_activated {
    my ($sheetName) = @_;
    loadStyleSheet($sheetName);
}

sub on_styleTextEdit_textChanged {
    this->{ui}->applyButton()->setEnabled(1);
}

sub on_applyButton_clicked {
    my $ui = this->{ui};
    qApp->setStyleSheet($ui->styleTextEdit()->toPlainText());
    $ui->applyButton()->setEnabled(0);
}

sub loadStyleSheet {
    my ($sheetName) = @_;
    my $ui = this->{ui};
    my $file = Qt4::File('qss/' . lc($sheetName) . '.qss');
    $file->open(Qt4::File::ReadOnly());
    my $styleSheet = $file->readAll()->data();

    $ui->styleTextEdit()->setPlainText($styleSheet);
    qApp->setStyleSheet($styleSheet);
    $ui->applyButton()->setEnabled(0);
}

1;
