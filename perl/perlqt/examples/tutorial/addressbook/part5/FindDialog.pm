package FindDialog;

use strict;
use warnings;
use Qt4;

use Qt4::isa qw( Qt4::Dialog );
use Qt4::slots
    findClicked => [];

# [constructor]
sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
    my $findLabel = Qt4::Label(this->tr('Enter the name of a contact:'));
    this->{lineEdit} = Qt4::LineEdit();

    this->{findButton} = Qt4::PushButton(this->tr('&Find'));
    this->{findText} = '';

    my $layout = Qt4::HBoxLayout();
    $layout->addWidget($findLabel);
    $layout->addWidget(this->{lineEdit});
    $layout->addWidget(this->{findButton});

    this->setLayout($layout);
    this->setWindowTitle(this->tr('Find a Contact'));
    this->connect(this->{findButton}, SIGNAL 'clicked()', this, SLOT 'findClicked()');
    this->connect(this->{findButton}, SIGNAL 'clicked()', this, SLOT 'accept()');
}
# [constructor]
# [findClicked() function]
sub findClicked
{
    my $text = this->{lineEdit}->text();

    if (!$text) {
        Qt4::MessageBox::information(this, this->tr('Empty Field'),
            this->tr('Please enter a name.'));
        return;
    } else {
        this->{findText} = $text;
        this->{lineEdit}->clear();
        this->hide();
    }
}
# [findClicked() function]
# [getFindText() function]
sub getFindText
{
    return this->{findText};
}
# [getFindText() function]

1;
