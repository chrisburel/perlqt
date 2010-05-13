package EditableSqlModel;

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
sub flags
{
    my ($index) = @_;
    my $flags = this->SUPER::flags($index);
    if ($index->column() == 1 || $index->column() == 2) {
        $flags |= Qt4::ItemIsEditable();
    }
    return $flags;
}
# [0]

# [1]
sub setData
{
    my ($index, $value) = @_;
    if ($index->column() < 1 || $index->column() > 2) {
        return 0;
    }

    my $primaryKeyIndex = this->SUPER::index($index->row(), 0);
    my $id = this->data($primaryKeyIndex)->toInt();

    this->clear();

    my $ok;
    if ($index->column() == 1) {
        $ok = this->setFirstName($id, $value->toString());
    } else {
        $ok = this->setLastName($id, $value->toString());
    }
    this->refresh();
    return $ok;
}
# [1]

sub refresh
{
    this->setQuery('select * from person');
    this->setHeaderData(0, Qt4::Horizontal(), Qt4::Variant(Qt4::String(Qt4::Object::tr('ID'))));
    this->setHeaderData(1, Qt4::Horizontal(), Qt4::Variant(Qt4::String(Qt4::Object::tr('First name'))));
    this->setHeaderData(2, Qt4::Horizontal(), Qt4::Variant(Qt4::String(Qt4::Object::tr('Last name'))));
}

# [2]
sub setFirstName
{
    my ($personId, $firstName) = @_;
    my $query = Qt4::SqlQuery();
    $query->prepare('update person set firstname = ? where id = ?');
    $query->addBindValue(Qt4::Variant(Qt4::String($firstName)));
    $query->addBindValue(Qt4::Variant(Qt4::String($personId)));
    return $query->exec();
}
# [2]

sub setLastName
{
    my ($personId, $lastName) = @_;
    my $query = Qt4::SqlQuery();
    $query->prepare('update person set lastname = ? where id = ?');
    $query->addBindValue($lastName);
    $query->addBindValue($personId);
    return $query->exec();
}

1;
