#***************************************************************************
#                          Qt3Support4.pm  -  Qt3Support perl client lib
#                             -------------------
#    begin                : 09-02-2010
#    copyright            : (C) 2010 by Chris Burel
#    email                : chrisburel@gmail.com
# ***************************************************************************

#***************************************************************************
# *                                                                         *
# *   This program is free software; you can redistribute it and/or modify  *
# *   it under the terms of the GNU General Public License as published by  *
# *   the Free Software Foundation; either version 2 of the License, or     *
# *   (at your option) any later version.                                   *
# *                                                                         *
# ***************************************************************************

package Qt3Support4::_internal;

use strict;
use warnings;
use QtCore4;
use base qw(Qt::_internal);

my %non3namedclasses;
@non3namedclasses{qw(
        QColorGroup
        QConstString
        QCustomEvent
        QMenuItem
        QTextIStream)} = undef;

sub init {
    foreach my $c ( @{getClassList()} ) {
        Qt3Support4::_internal->init_class($c);
    }
    foreach my $e ( @{getEnumList()} ) {
        Qt3Support4::_internal->init_enum($e);
    }
}

sub normalize_classname {
    my ( $self, $cxxClassName ) = @_;
    if ( $cxxClassName =~ m/^Q3/ ) {
        $cxxClassName =~ s/^Q3/Qt3::/;
    }
    elsif ( defined $non3namedclasses{$cxxClassName} ) {
        $cxxClassName =~ s/^Q/Qt::/;
    }
    else {
        $cxxClassName = $self->SUPER::normalize_classname( $cxxClassName );
    }
    return $cxxClassName;
}

package Qt3Support4;

use strict;
use warnings;
use QtCore4;
use QtGui4;
use QtNetwork4;
use QtSql4;

require XSLoader;

our $VERSION = '0.01';

XSLoader::load('Qt3Support4', $VERSION);

Qt3Support4::_internal::init();

1;

