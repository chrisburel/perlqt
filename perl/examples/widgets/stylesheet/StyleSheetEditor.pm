package StyleSheetEditor;

use strict;
use warnings;
use blib;

use Qt;
use Qt::isa qw( Qt::Dialog );

use Ui_StyleSheetEditor;

use Qt::slots
    on_styleCombo_activated => ['Qt::String'],
    on_styleSheetCombo_activated => ['Qt::String'],
    on_styleTextEdit_textChanged => [],
    on_applyButton_clicked => [];

sub NEW {
    my ( $class, $parent ) = @_;
    $class->SUPER::NEW( $parent );
    my $ui = Ui_StyleSheetEditor->setupUi(this);
    this->{ui} = $ui;

    my $regExp = Qt::RegExp("Q(.*)Style");
    my $defaultStyle = Qt::Application::style()->metaObject()->className();

    if ($defaultStyle eq 'Qt::MacStyle') {
        $defaultStyle = 'Macintosh (Aqua)';
    }
    elsif ($regExp->exactMatch($defaultStyle)) {
        $defaultStyle = $regExp->cap(1);
    }

    $ui->styleCombo()->addItems(Qt::StyleFactory::keys());
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
    my $file = Qt::File('qss/' . $sheetName->toLower() + '.qss');
    $file->open(Qt::File::ReadOnly());
    my $styleSheet = $file->readAll();

    $ui->styleTextEdit()->setPlainText($styleSheet);
    qApp->setStyleSheet($styleSheet);
    $ui->applyButton()->setEnabled(0);
}

1;
