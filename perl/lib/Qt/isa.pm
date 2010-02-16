package Qt::isa;

use strict;
use warnings;

sub import {
    no strict 'refs';
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
        no warnings; # Name "Foo::META" used only once
        push @{ $caller . '::ISA' }, $super;
        push @{ $caller . '::SUPER::ISA' }, $caller;
        push @{ ${$caller . '::META'}{'superClass'} }, $super;

        # Convert ::'s to a filepath /
        (my $super_pm = $super.'.pm') =~ s!::!/!g;
        unless( defined $Qt::_internal::package2classId{$super} ){
            require $super_pm;
        }
    }

    # This hash is used to get an object blessed to the right thing, so that
    # when we call SUPER(), we get this blessed object back.
    ${$caller.'::_INTERNAL_STATIC_'}{'SUPER'} = bless {}, "  $caller";
    Qt::_internal::installsuper($caller);# unless defined &{ $caller.'::SUPER' };

    # Make it so that 'use <packagename>' makes a subroutine called
    # <packagename> that calls ->new
    *{ $caller . '::import' } = sub {
        # Name is the full package name being loaded, incaller is the package
        # doing the loading
        my $name = shift;    # classname = function-name
        my $incaller = (caller)[0];
        $incaller = (caller(1))[0] if $incaller eq 'if';
        { 
            *{ "$name" } = sub {

                $name->new(@_);
            } unless defined &{ "$name" };
        };
        {
            *{ "$incaller\::$name" } = sub {
                $name->new(@_);
            } unless defined &{ "$incaller\::$name" };
        };

        if ( grep { $_ eq 'Exporter' } @{"$name\::ISA"} ) {
            $name->export($incaller, @_);
        }
    };

    Qt::_internal::installautoload("  $caller");
    Qt::_internal::installautoload(" $caller");
    Qt::_internal::installautoload($caller);
    {
        package Qt::AutoLoad;
        my $autosub = \&{ "  $caller\::_UTOLOAD" };
        *{ "  $caller\::AUTOLOAD" } = sub { &$autosub };        
        $autosub = \&{ " $caller\::_UTOLOAD" };
        *{ " $caller\::AUTOLOAD" } = sub { &$autosub };        
        $autosub = \&{ "$caller\::_UTOLOAD" };
        *{ "$caller\::AUTOLOAD" } = sub { &$autosub };
    }

    Qt::_internal::installthis($caller);
}
1; # Is the loneliest number that you'll ever do
