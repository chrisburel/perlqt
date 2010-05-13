package TableEditor;

use strict;
use warnings;
use Qt4;

# [0]
use Qt4::isa qw( Qt4::Dialog );
use Qt4::slots
    submit => [];
# [0]

# [0]
sub NEW 
{
    my ($class, $tableName, $parent) = @_;
    $class->SUPER::NEW($parent);

    this->{model} = Qt4::SqlTableModel(this);
    this->{model}->setTable($tableName);
    this->{model}->setEditStrategy(Qt4::SqlTableModel::OnManualSubmit());
    this->{model}->select();

    this->{model}->setHeaderData(0, Qt4::Horizontal(), Qt4::Variant(Qt4::String(this->tr('ID'))));
    this->{model}->setHeaderData(1, Qt4::Horizontal(), Qt4::Variant(Qt4::String(this->tr('First name'))));
    this->{model}->setHeaderData(2, Qt4::Horizontal(), Qt4::Variant(Qt4::String(this->tr('Last name'))));

# [0] //! [1]
    my $view = Qt4::TableView();
    $view->setModel(this->{model});
# [1]

# [2]
    this->{submitButton} = Qt4::PushButton(this->tr('Submit'));
    this->{submitButton}->setDefault(1);
    this->{revertButton} = Qt4::PushButton(this->tr('&Revert'));
    this->{quitButton} = Qt4::PushButton(this->tr('Quit'));

    this->{buttonBox} = Qt4::DialogButtonBox(Qt4::Vertical());
    this->{buttonBox}->addButton(this->{submitButton}, Qt4::DialogButtonBox::ActionRole());
    this->{buttonBox}->addButton(this->{revertButton}, Qt4::DialogButtonBox::ActionRole());
    this->{buttonBox}->addButton(this->{quitButton}, Qt4::DialogButtonBox::RejectRole());
# [2]

# [3]
    this->connect(this->{submitButton}, SIGNAL 'clicked()', this, SLOT 'submit()');
    this->connect(this->{revertButton}, SIGNAL 'clicked()', this->{model}, SLOT 'revertAll()');
    this->connect(this->{quitButton}, SIGNAL 'clicked()', this, SLOT 'close()');
# [3]

# [4]
    my $mainLayout = Qt4::HBoxLayout();
    $mainLayout->addWidget($view);
    $mainLayout->addWidget(this->{buttonBox});
    this->setLayout($mainLayout);

    this->setWindowTitle(this->tr('Cached Table'));
}
# [4]

# [5]
sub submit
{
    this->{model}->database()->transaction();
    if (this->{model}->submitAll()) {
        this->{model}->database()->commit();
    } else {
        this->{model}->database()->rollback();
        Qt4::MessageBox::warning(this, this->tr('Cached Table'),
                     sprintf this->tr('The database reported an error: %s'),
                             this->{model}->lastError()->text());
    }
}
# [5]

1;
