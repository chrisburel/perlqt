package QtSimple::isa;
use strict;
sub import {
    no strict 'refs';
    # Class will be QtSimple::isa.  Caller is the name of the package doing the use.
    my $class = shift;
    my $caller = (caller)[0];

    # Trick 'use' into believing the file for this class has been read, and associate it with this file
    my $pm = $caller . ".pm";
    $pm =~ s!::!/!g;
    unless(exists $::INC{$pm}) {
        $::INC{$pm} = $::INC{"QtSimple/isa.pm"};
    }

    # Define the QtSimple::ISA array
    for my $super (@_) {
        push @{ $caller . '::ISA' }, $super;
    }

    *{ $caller . '::import' } = sub {
        print "Running $caller\::import\n";
        # Name is the full package name being loaded, incaller is the package doing the loading.
        my $name = shift;    # classname = function-name
        my $incaller = (caller)[0];
        $incaller = (caller(1))[0] if $incaller eq 'if'; # work-around bug in package 'if'  pre 0.02
        printf("name=%s incaller=%s\n", $name, $incaller);

        # cname is the 'filename' of the package, everything after the last '::'
        # p is the 'basename', everything up to and including the last '::'
        my $cname = $name;
        $cname =~ s/.*:://;
        $p =~ s/(.*::).*/$1/;

        
        { 
            *{ "$name" } = sub {

                $name->new(@_);
            } unless defined &{ "$name" };
        };
        $p eq ($incaller=~ /.*::/ ? ($p ? $& : '') : '') and do
        {
            *{ "$incaller\::$cname" } = sub {
                $name->new(@_);
            } unless defined &{ "$incaller\::$cname" };
        };
    };

    QtSimple::_internal::installautoload(" $caller");
    QtSimple::_internal::installautoload($caller);
    {
        package QtSimple::AutoLoad;
        my $autosub = \&{ " $caller\::_UTOLOAD" };
        *{ "  $caller\::AUTOLOAD" } = sub { &$autosub };        
        $autosub = \&{ "$caller\::_UTOLOAD" };
        *{ "$caller\::AUTOLOAD" } = sub { &$autosub };
    }
}
1; # Is the loneliest number that you'll ever do
