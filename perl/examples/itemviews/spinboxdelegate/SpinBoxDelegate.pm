package SpinBoxDelegate;

use strict;
use warnings;
use blib;

use Qt4;
use Qt4::isa qw( Qt4::ItemDelegate );

# [0]
sub NEW {
    shift->SUPER::NEW();
}
# [0]

# [1]
sub createEditor {
    my ( $parent, $option, $index ) = @_;
    my $editor = Qt4::SpinBox($parent);
    $editor->setMinimum(0);
    $editor->setMaximum(100);

    return $editor;
}
# [1]

# [2]
sub setEditorData {
    my ($editor, $index) = @_;
    my $value = $index->model()->data($index, Qt4::EditRole())->toInt();

    my $spinBox = $editor;
    $spinBox->setValue($value);
}
# [2]

# [3]
sub setModelData {
    my ($editor, $model, $index) = @_;
    my $spinBox = $editor;
    $spinBox->interpretText();
    my $value = Qt4::Variant($spinBox->value());

    $model->setData($index, $value, Qt4::EditRole());
}
# [3]

# [4]
sub updateEditorGeometry {
    my ($editor, $option, $index) = @_;
    $editor->setGeometry($option->rect);
}
# [4]

1;
