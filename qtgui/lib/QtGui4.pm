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
use base qw(Qt::_internal);

sub init {
    foreach my $c ( @{getClassList()} ) {
        QtGui4::_internal->init_class($c);
    }
    foreach my $e ( @{getEnumList()} ) {
        QtGui4::_internal->init_enum($e);
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

package Qt;

use strict;
use warnings;

sub Qt::GraphicsItem::ON_DESTROY {
    package Qt::_internal;
    my $parent = Qt::this()->parentItem();
    $parent = Qt::this()->scene() if !$parent;
    if( defined $parent ) {
        my $ptr = sv_to_ptr(Qt::this());
        ${ $parent->{'hidden children'} }{ $ptr } = Qt::this();
        Qt::this()->{'has been hidden'} = 1;
        return 1;
    }
    return 0;
}

sub Qt::GraphicsWidget::ON_DESTROY {
    Qt::GraphicsItem::ON_DESTROY();
}

sub Qt::GraphicsObject::ON_DESTROY {
    Qt::GraphicsItem::ON_DESTROY();
}

package Qt::PolygonF;

sub EXISTS {
    my ( $index ) = @_;
    return Qt::this()->exists($index);
}

sub FETCH {
    my ( $index ) = @_;
    return Qt::this()->at($index);
}

sub FETCHSIZE {
    return Qt::this()->size();
}

sub STORE {
    my ( $index, $value ) = @_;
    return Qt::this()->store($index, $value);
}

1;
