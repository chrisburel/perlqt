package CustomSqlModel;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::SqlQueryModel );

sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
}

# [0]
sub data
{
    my ($index, $role) = @_;
    my $value = this->SUPER::data($index, $role);
    if ($value->isValid() && $role == Qt4::DisplayRole()) {
        if ($index->column() == 0) {
            return Qt4::Variant(Qt4::String('#' . $value->toString()));
        }
        elsif ($index->column() == 2) {
            return Qt4::Variant(Qt4::String(uc $value->toString()));
        }
    }
    if ($role == Qt4::TextColorRole() && $index->column() == 1) {
        return Qt4::qVariantFromValue(Qt4::Color(Qt4::blue()));
    }
    return $value;
}
# [0]

1;
