package QtSimple::base;

use strict;

sub new {
    return shift->NEW(@_);
}

package QtSimple::_internal;

use strict;

our %package2classid;

sub init_class {
    no strict 'refs';
    my ($cxxClassName) = @_;
    my $perlClassName = $cxxClassName;

    # Prepend my package namespace
    $perlClassName =~ s/^/QtSimple::/;

    # Create the Perl fully-qualified package name -> classId relationship
    # Why use QHash or QAsciiDict when perl has built-in hashes?
    my $classId = QtSimple::_internal::idClass($cxxClassName);
    $package2classid{$perlClassName} = $classId; # My insert_pclassid

    # Setting the @isa array makes it look up the perl inheritance list to
    # find the new() function
    my @isa = getIsa($classId);
    for my $super (@isa) {
        $super =~ /^QtSimple/ and next;
        $super =~ s/^/QtSimple::/ and next;
    }
    @isa = ("QtSimple::base") unless @isa;
    *{ "$perlClassName\::ISA" } = \@isa;

    installautoload("$perlClassName");
    {
        package QtSimple::AutoLoad;
        my $closure = \&{ "$perlClassName\::_UTOLOAD" };
        *{ $perlClassName . "::AUTOLOAD" } = sub{ &$closure };
    }

    installautoload( " $perlClassName");
    {
        package QtSimple::AutoLoad;
        my $closure = \&{ " $perlClassName\::_UTOLOAD" };
        *{ " $perlClassName\::AUTOLOAD" } = sub{ &$closure };
    }

    *{ "$perlClassName\::NEW" } = sub {
        my $perlClassName = shift;
        $QtSimple::AutoLoad::AUTOLOAD = "$perlClassName\::$cxxClassName";
        my $autoload = "$perlClassName\::_UTOLOAD";
        my $retval; 
        {
            no warnings;
            $retval = &$autoload;
        }
        return $retval;
    } unless defined &{"$perlClassName\::NEW"};

    *{ $perlClassName } = sub {
        $perlClassName->new(@_);
    } unless defined &{ $perlClassName };

}

sub init {
    no warnings;
    my $classes = getClassList();
    foreach my $perlClassName (@$classes) {
        init_class($perlClassName);
    }
}

package QtSimple;

use 5.008006;
use strict;
use warnings;
require XSLoader;

require Exporter;

our $VERSION = '0.01';

XSLoader::load('QtSimple', $VERSION);

QtSimple::_internal::init();

# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

QtSimple - Perl extension for blah blah blah

=head1 SYNOPSIS

  use QtSimple;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for QtSimple, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Chris Burel, E<lt>chris@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 by Chris Burel

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
