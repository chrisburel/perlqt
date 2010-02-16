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

package Qt::enum::_overload;

use strict;

no strict 'refs';

use overload
    "fallback" => 1,
    "==" => "Qt::enum::_overload::op_equal",
    "+"  => "Qt::enum::_overload::op_plus",
    "|"  => "Qt::enum::_overload::op_or";

sub op_equal {
    return 1 if ${$_[0]} == ${$_[1]};
    return 0;
}

sub op_plus {
    return bless( \(${$_[0]} + ${$_[1]}), ref $_[0] );
}

sub op_or {
    return bless( \(${$_[0]} | ${$_[1]}), ref $_[0] );
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

    # Get the super class's meta object for sig/slot inheritance
    # Recurse up through ISA to find it
    my $parentMeta;
    my $parentClassId;

    # This seems wrong...
    my $parentClass = (@{$class."::ISA"})[0]; 
    if( !$package2classid{$parentClass} ) {
        $parentMeta = &{$parentClass."::metaObject"};
    }
    else {
        $parentClassId = $package2classid{$parentClass};
    }

    # Generate data to create the meta object
    my( $stringdata, $data ) = makeMetaData( $class );
    $meta->{object} = Qt::_internal::make_metaObject(
        $parentClassId,
        $parentMeta,
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
    my $enums = getEnumList();

    no strict 'refs';
    foreach my $enumName (@$enums) {
        $enumName =~ s/^const //;
        @{$enumName."::ISA"} = ("Qt::enum::_overload");
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

    @$signals = () if !defined @$signals;
    @$slots = () if !defined @$slots;

    # Each entry in 'stringdata' corresponds to a string in the
    # qt_meta_stringdata_<classname> structure.

    #
    # From the enum MethodFlags in qt-copy/src/tools/moc/generator.cpp
    #
    my $AccessPrivate = 0x00;
    my $AccessProtected = 0x01;
    my $AccessPublic = 0x02;
    my $MethodMethod = 0x00;
    my $MethodSignal = 0x04;
    my $MethodSlot = 0x08;
    my $MethodCompatibility = 0x10;
    my $MethodCloned = 0x20;
    my $MethodScriptable = 0x40;

    my $data = [1,               #revision
                0,               #str index of classname
                0, 0,            #don't have classinfo
                scalar @$signals + scalar @$slots, #number of sig/slots
                10,              #do have methods
                0, 0,            #no properties
                0, 0,            #no enums/sets
    ];

    my $stringdata = "$classname\0\0";
    my $nullposition = length( $stringdata ) - 1;

    # Build the stringdata string, storing the indexes in data
    foreach my $signal ( @$signals ) {
        my $curPosition = length $stringdata;

        # Add this signal to the stringdata
        $stringdata .= $signal->{signature} . "\0" ;

        push @$data, $curPosition; #signature
        push @$data, $nullposition; #parameter names
        push @$data, $nullposition; #return type, void
        push @$data, $nullposition; #tag
        push @$data, $MethodSignal | $AccessProtected; # flags
    }

    foreach my $slot ( @$slots ) {
        my $curPosition = length $stringdata;

        # Add this slot to the stringdata
        $stringdata .= $slot->{signature} . "\0" ;

        push @$data, $curPosition; #signature
        push @$data, $nullposition; #parameter names
        push @$data, $nullposition; #return type, void
        push @$data, $nullposition; #tag
        push @$data, $MethodSlot | $AccessPublic; # flags
    }

    push @$data, 0; #eod

    return ($stringdata, $data);
}

package Qt;

use 5.008006;
use strict;
use warnings;
require XSLoader;

require Exporter;

our $VERSION = '0.01';

our @EXPORT = qw( SIGNAL SLOT emit CAST );

XSLoader::load('Qt', $VERSION);

Qt::_internal::init();

sub SIGNAL ($) { '2' . $_[0] }
sub SLOT ($) { '1' . $_[0] }
sub emit (@) { pop @_ }
sub CAST ($$) {
    my( $var, $class ) = @_;
    if( ref $var ) {
        return bless( $var, $class );
    }
    else {
        return bless( \$var, $class );
    }
}

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
