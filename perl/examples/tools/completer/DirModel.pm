package DirModel;
use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::DirModel );

# With a Qt4::DirModel, set on a view, you will see 'Program Files' in the view
# But with this model, you will see 'C:\Program Files' in the view.
# We acheive this, by having the data() return the entire file path for
# the display role. Note that the Qt4::EditRole over which the Qt4::Completer
# looks for matches is left unchanged

# [0]
sub NEW {
    my ( $class, $parent ) = @_;
    $class->SUPER::NEW( $parent );
}
# [0]

# [1]
sub data
{
    my ($index, $role) = @_;
    if ($role == Qt4::DisplayRole() && $index->column() == 0) {
        my $path = Qt4::Dir::toNativeSeparators(this->filePath($index));
        if ( substr( $path, -1 ) eq chr( Qt4::Dir::separator()->toAscii() ) ) {
            $DB::single = 1;
            chop $path;
        }
        return Qt4::Variant(Qt4::String($path));
    }

    return this->SUPER::data($index, $role);
}
# [1]

1;
