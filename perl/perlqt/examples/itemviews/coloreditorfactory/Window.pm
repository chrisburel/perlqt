package Window;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::Widget );
use ColorListEditor;

# [0]
sub NEW
{
    my ($class) = @_;
    $class->SUPER::NEW();
    my $factory = Qt4::ItemEditorFactory();

    my $colorListCreator =
        Qt4::StandardItemEditorCreator();

    $factory->registerEditor(Qt4::Variant::Color(), $colorListCreator);

    Qt4::ItemEditorFactory::setDefaultFactory($factory);

    this->createGUI();
}
# [0]

sub createGUI
{
    my $list = [
        [this->tr('Alice'), Qt4::Color('aliceblue')],
        [this->tr('Neptun'), Qt4::Color('aquamarine')],
        [this->tr('Ferdinand'), Qt4::Color('springgreen')]
    ];

    my $table = Qt4::TableWidget(3, 2);
    $table->setHorizontalHeaderLabels([this->tr('Name'), this->tr('Hair Color')]);
    $table->verticalHeader()->setVisible(0);
    $table->resize(150, 50);

    foreach my $i (0..2) {
        my $pair = $list->[$i];

        my $nameItem = Qt4::TableWidgetItem($pair->[0]);
        my $colorItem = Qt4::TableWidgetItem();
        $colorItem->setData(Qt4::DisplayRole(), $pair->[1]);

        $table->setItem($i, 0, $nameItem);
        $table->setItem($i, 1, $colorItem);
    }
    $table->resizeColumnToContents(0);
    $table->horizontalHeader()->setStretchLastSection(1);

    my $layout = Qt4::GridLayout();
    $layout->addWidget($table, 0, 0);

    this->setLayout($layout);

    this->setWindowTitle(this->tr('Color Editor Factory'));
}

1;
