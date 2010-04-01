#***************************************************************************
#                          KIO4.pm  -  KIO perl client lib
#                             -------------------
#    begin                : 04-01-2010
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

package KIO4::_internal;

use strict;
use warnings;
use KDECore4;
use base qw(KDECore4::_internal);

sub init {
    foreach my $c ( @{getClassList()} ) {
        KIO4::_internal->init_class($c);
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

package KIO4;

use strict;
use warnings;
use KDECore4;

require XSLoader;

our $VERSION = '0.01';

XSLoader::load('KIO4', $VERSION);

KIO4::_internal::init();

1;

