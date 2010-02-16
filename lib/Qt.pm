package Qt::base;

use strict;
sub this () {}

sub new {
    no strict 'refs';
    # Store whatever current 'this' value we've got
    my $packageThis = Qt::this();
    # Overwrites the 'this' value
    shift->NEW(@_);
    # Get the return value
    my $ret = Qt::this();
    # Restore package's this
    Qt::_internal::setThis($packageThis);
    # Give back the new value
    return $ret;
}

package Qt::_internal;

use strict;

our %package2classid;

sub getMetaObject {
    no strict 'refs';
    my $class = shift;
    my $meta = \%{ $class . '::META' };

    # If no signals/slots/properties have been added since the last time this
    # was asked for, return the saved one.
    return $meta->{object} if $meta->{object} and !$meta->{changed};

    # Generate data to create the meta object
    my( $stringdata, $data ) = makeMetaData( $class );
    $meta->{object} = Qt::_internal::make_metaObject(
        $class,
        undef, #Qt::this()->staticMetaObject,
        $stringdata,
        $data );

    $meta->{changed} = 0;
    return $meta->{object};
}

sub init_class {
    no strict 'refs';
    my ($cxxClassName) = @_;
    my $perlClassName = $cxxClassName;

    # Prepend my package namespace
    $perlClassName =~ s/^/Qt::/;

    # Create the Perl fully-qualified package name -> classId relationship
    # Why use QHash or QAsciiDict when perl has built-in hashes?
    my $classId = Qt::_internal::idClass($cxxClassName);
    $package2classid{$perlClassName} = $classId; # My insert_pclassid

    # Setting the @isa array makes it look up the perl inheritance list to
    # find the new() function
    my @isa = getIsa($classId);
    for my $super (@isa) {
        $super =~ /^Qt/ and next;
        $super =~ s/^/Qt::/ and next;
    }
    @isa = ("Qt::base") unless @isa;
    *{ "$perlClassName\::ISA" } = \@isa;

    installautoload("$perlClassName");
    {
        package Qt::AutoLoad;
        my $closure = \&{ "$perlClassName\::_UTOLOAD" };
        *{ $perlClassName . "::AUTOLOAD" } = sub{ &$closure };
    }

    installautoload( " $perlClassName");
    {
        package Qt::AutoLoad;
        my $closure = \&{ " $perlClassName\::_UTOLOAD" };
        *{ " $perlClassName\::AUTOLOAD" } = sub{ &$closure };
    }

    *{ "$perlClassName\::NEW" } = sub {
        my $perlClassName = shift;
        $Qt::AutoLoad::AUTOLOAD = "$perlClassName\::$cxxClassName";
        my $autoload = "$perlClassName\::_UTOLOAD";
        {
            no warnings;
            setThis( bless &$autoload, " $perlClassName" );
        }
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

sub makeMetaData {
    no strict 'refs';
    my ( $classname ) = @_;
    my $meta = \%{ $classname . '::META' };
    my $classinfos = $meta->{classinfos};
    my $dbus = $meta->{dbus};
    my $signals = $meta->{signals};
    my $slots = $meta->{slots};

    # Each entry in 'stringdata' corresponds to a string in the
    # qt_meta_stringdata_<classname> structure.
    # 'pack_string' is used to convert 'stringdata' into the
    # binary sequence of null terminated strings for the metaObject
    #my @stringdata;
    #my $pack_string = "";
    #my $string_table = string_table_handler(stringdata, pack_string);

    my $data = [1,                   # revision
                0,                   # classname
                0, 0,                # classinfo
                2, 10,               # methods
                0, 0,                # properties
                0, 0,                # enums/sets
                19, 10, 9, 9, 0x05,  # signals
                43, 37, 9, 9, 0x0a,  # slots
                0];                  # eod
    my $stringdata = 
        "LCDRange\0\0newValue\0valueChanged(int)\0" .
        "value\0setValue(int)\0"
    ;

    return ($stringdata, $data);
}

package Qt;

use 5.008006;
use strict;
use warnings;
require XSLoader;

require Exporter;

our $VERSION = '0.01';

our @EXPORT = qw( SIGNAL SLOT emit );

XSLoader::load('Qt', $VERSION);

Qt::_internal::init();

sub SIGNAL ($) { '2' . $_[0] }
sub SLOT ($) { '1' . $_[0] }
sub emit (@) { pop @_ }

sub import { goto &Exporter::import }
# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Qt - Perl extension for blah blah blah

=head1 SYNOPSIS

  use Qt;
  blah blah blah

=head1 DESCRIPTION

Stub documentation for Qt, created by h2xs. It looks like the
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
