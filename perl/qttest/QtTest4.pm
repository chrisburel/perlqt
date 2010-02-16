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

sub init {
    foreach my $c ( @{getClassList()} ) {
        Qt4::_internal::init_class($c);
        #my $classname = Qt4::_internal::normalize_classname($c);
        #my $id = Qt4::_internal::idClass($c);
        #$Qt4::_internal::package2classId{$classname} = $id;
        #$Qt4::_internal::classId2package{$id} = $classname;
        #klass = Qt4::_internal::isQObject(c) ? Qt4::_internal::create_qobject_class(classname, Qt)  : Qt4::_internal::create_qt_class(classname, Qt);
            #Qt4::_internal::classes[classname] = klass unless klass.nil?
    }
}

package QtTest4;

use strict;
use warnings;
use Qt4;

require XSLoader;

our $VERSION = '0.01';

XSLoader::load('QtTest4', $VERSION);

QtTest4::_internal::init();

1;
