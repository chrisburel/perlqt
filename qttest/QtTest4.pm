#***************************************************************************
#                          QtTest4.pm  -  QtTest perl client lib
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

package QtTest4::_internal;

use strict;
use warnings;
use QtCore4;

use base qw(Qt4::_internal);

sub init {
    foreach my $c ( @{getClassList()} ) {
        QtTest4::_internal->init_class($c);
    }
}

sub normalize_classname {
    my $cxxClassName = $_[1];
    $cxxClassName =~ s/^Q(?=[A-Z])/Qt4::/;
    return $cxxClassName;
}

package QtTest4;

use strict;
use warnings;
use QtCore4;

require XSLoader;

our $VERSION = '0.01';

XSLoader::load('QtTest4', $VERSION);

QtTest4::_internal::init();

1;
