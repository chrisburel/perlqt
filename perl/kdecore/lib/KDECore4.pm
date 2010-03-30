#***************************************************************************
#                          KDECore4.pm  -  KDECore perl client lib
#                             -------------------
#    begin                : 07-12-2009
#    copyright            : (C) 2009 by Chris Burel
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

package KDECore4::_internal;

use strict;
use warnings;

use base qw(Qt4::_internal);

sub init {
    foreach my $c ( @{getClassList()} ) {
        KDECore4::_internal->init_class($c);
    }
}

sub normalize_classname {
    my ( $self, $cxxClassName ) = @_;
    if( $cxxClassName =~ m/^K/ ) {
        $cxxClassName =~ s/^K(?=[A-Z])/KDE::/;
    }
    else {
        $cxxClassName = $self->SUPER::normalize_classname( $cxxClassName );
    }
    return $cxxClassName;
}

package KDECore4;

use strict;
use warnings;
use Qt4;

require XSLoader;

our $VERSION = '0.01';

XSLoader::load('KDECore4', $VERSION);

KDECore4::_internal::init();

1;
