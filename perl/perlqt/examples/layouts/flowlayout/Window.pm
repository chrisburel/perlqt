package Window;

use strict;
use warnings;
use Qt4;
# [0]
use Qt4::isa qw( Qt4::Widget );
# [0]
use FlowLayout;

# [1]
sub NEW
{
    my ($class) = @_;
    $class->SUPER::NEW();
    my $flowLayout = FlowLayout();

    $flowLayout->addWidget(Qt4::PushButton(this->tr('Short')));
    $flowLayout->addWidget(Qt4::PushButton(this->tr('Longer')));
    $flowLayout->addWidget(Qt4::PushButton(this->tr('Different text')));
    $flowLayout->addWidget(Qt4::PushButton(this->tr('More text')));
    $flowLayout->addWidget(Qt4::PushButton(this->tr('Even longer button text')));
    this->setLayout($flowLayout);

    this->setWindowTitle(this->tr('Flow Layout'));
}
# [1]

1;
