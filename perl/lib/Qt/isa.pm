package Qt::isa;

use strict;
use warnings;

# meta-hackery tools
my $A = sub {my ($n) = @_; no strict 'refs'; \@{$n}};
my $H = sub {my ($n) = @_; no strict 'refs'; no warnings 'once'; \%{$n}};
my $ISUB = sub {my ($n, $s) = @_; no strict 'refs'; *{$n} = $s};

sub import {
    # Class will be Qt::isa.  Caller is the name of the package doing the use.
    my $class = shift;
    my $caller = (caller)[0];

    # Trick 'use' into believing the file for this class has been read, and
    # associate it with this file
    my $pm = $caller . ".pm";
    $pm =~ s!::!/!g;
    unless(exists $::INC{$pm}) {
        $::INC{$pm} = $::INC{"Qt/isa.pm"};
    }

    # Define the Qt::ISA array
    # Load the file if necessary
    for my $super (@_) {
        push @{$A->($caller . '::ISA')}, $super;
        push @{$H->($caller . '::META')->{'superClass'}}, $super;

        # Convert ::'s to a filepath /
        (my $super_pm = $super.'.pm') =~ s!::!/!g;
        unless( defined $Qt::_internal::package2classId{$super} ){
            require $super_pm;
        }
    }

    # This hash is used to get an object blessed to the right thing, so that
    # when we call SUPER(), we get this blessed object back.
    {
        my $superthing = bless {}, "  $caller";
        $ISUB->($caller.'::SUPER', sub {$superthing});
    }

    # Make it so that 'use <packagename>' makes a subroutine called
    # <packagename> that calls ->new
    $ISUB->($caller . '::import', sub {
        # Name is the full package name being loaded, incaller is the package
        # doing the loading
        my $name = shift;    # classname = function-name
        my $incaller = (caller)[0];
        $ISUB->( $name, sub { $name->new(@_); } )
            unless defined &{"$name"};
        $ISUB->("$incaller\::$name", sub { $name->new(@_) })
            unless defined &{"$incaller\::$name"};

        $name->export($incaller, @_)
            if(grep { $_ eq 'Exporter' } @{$A->("$name\::ISA")});
    });

    foreach my $sp ('  ', ' ', '') {
        my $where = $sp . $caller;
        Qt::_internal::installautoload($where);
        package Qt::AutoLoad;
        my $autosub = \&{$where . '::_UTOLOAD'};
        $ISUB->($where.'::AUTOLOAD', sub { &$autosub });
    }

    Qt::_internal::installthis($caller);
}
1; # Is the loneliest number that you'll ever do
