package Window;

use strict;
use warnings;
use Qt;
# [0]
use Qt::isa qw( Qt::GraphicsWidget );
# [0]
use LayoutItem;

sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent, Qt::Window());
# [0]
    my $windowLayout = Qt::GraphicsLinearLayout(Qt::Vertical());
    my $linear = Qt::GraphicsLinearLayout($windowLayout);
    my $item = LayoutItem();
    $linear->addItem($item);
    $linear->setStretchFactor($item, 1);
# [0]

# [1]
    $item = LayoutItem();
    $linear->addItem($item);
    $linear->setStretchFactor($item, 3);
    $windowLayout->addItem($linear);
# [1]

# [2]
    my $grid = Qt::GraphicsGridLayout($windowLayout);
    $item = LayoutItem();
    $grid->addItem($item, 0, 0, 4, 1);
    $item = LayoutItem();
    $item->setMaximumHeight($item->minimumHeight());
    $grid->addItem($item, 0, 1, 2, 1, Qt::AlignVCenter());
    $item = LayoutItem();
    $item->setMaximumHeight($item->minimumHeight());
    $grid->addItem($item, 2, 1, 2, 1, Qt::AlignVCenter());
    $item = LayoutItem();
    $grid->addItem($item, 0, 2);
    $item = LayoutItem();
    $grid->addItem($item, 1, 2);
    $item = LayoutItem();
    $grid->addItem($item, 2, 2);
    $item = LayoutItem();
    $grid->addItem($item, 3, 2);
    $windowLayout->addItem($grid);
# [2]

# [3]
    this->setLayout($windowLayout);
    this->setWindowTitle(this->tr('Basic Graphics Layouts Example'));
# [3]

}

1;
