#***************************************************************************
#                          QtGui4.pm  -  QtGui perl client lib
#                             -------------------
#    begin                : 03-29-2010
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

package QtGui4::_internal;

use strict;
use warnings;

use QtCore4;
use base qw(Qt4::_internal);

sub init {
    foreach my $c ( @{getClassList()} ) {
        QtGui4::_internal->init_class($c);
    }
}

package QtGui4;

use strict;
use warnings;
use QtCore4;

require XSLoader;

our $VERSION = '0.01';

XSLoader::load('QtGui4', $VERSION);

QtGui4::_internal::init();

1;
