package AddressBook;

use strict;
use warnings;
use Qt4;

# [class definition]
use Qt4::isa qw( Qt4::Widget );
# [class definition]

# [constructor and input fields]
sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
    my $nameLabel = Qt4::Label(this->tr('Name:'));
    this->{nameLine} = Qt4::LineEdit();

    my $addressLabel = Qt4::Label(this->tr('Address:'));
    this->{addressText} = Qt4::TextEdit();
# [constructor and input fields]

# [layout]
    my $mainLayout = Qt4::GridLayout();
    $mainLayout->addWidget($nameLabel, 0, 0);
    $mainLayout->addWidget(this->{nameLine}, 0, 1);
    $mainLayout->addWidget($addressLabel, 1, 0, Qt4::AlignTop());
    $mainLayout->addWidget(this->{addressText}, 1, 1);
# [layout]

#[setting the layout]    
    this->setLayout($mainLayout);
    this->setWindowTitle(this->tr('Simple Address Book'));
}
# [setting the layout]

1;
