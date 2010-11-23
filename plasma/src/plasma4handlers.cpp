/***************************************************************************
                          plasma4handlers.cpp  -  Plasma specific marshallers
                             -------------------
    begin                : 04-02-2010
    copyright            : (C) 2010 Chris Burel
    email                : chrisburel@gmail.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either vesion 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
}

#include <smokeperl.h>
#include <marshall_macros.h>
#include <plasma/containment.h>
#include <plasma/applet.h>
#include <plasma/extenderitem.h>

extern void marshall_QHashQStringQVariant(Marshall *m);

DEF_LIST_MARSHALLER( PlasmaContainmentList, QList<Plasma::Containment*>, Plasma::Containment )
DEF_LIST_MARSHALLER( PlasmaAppletList, QList<Plasma::Applet*>, Plasma::Applet )
DEF_LIST_MARSHALLER( PlasmaExtenderItemList, QList<Plasma::ExtenderItem*>, Plasma::ExtenderItem )


TypeHandler Plasma4_handlers[] = {
    { "QHash<QString,QVariant>", marshall_QHashQStringQVariant },
    { "QHash<QString,QVariant>&", marshall_QHashQStringQVariant },
    { "const Plasma::DataEngine::Data", marshall_QHashQStringQVariant },
    { "const Plasma::DataEngine::Data&", marshall_QHashQStringQVariant },
    { "QList<Plasma::Containment*>", marshall_PlasmaContainmentList },
    { "QList<Plasma::Containment*>&", marshall_PlasmaContainmentList },
    { "Plasma::Applet::List", marshall_PlasmaAppletList },
    { "QList<Plasma::ExtenderItem*>", marshall_PlasmaExtenderItemList },
    { "QList<Plasma::ExtenderItem*>&", marshall_PlasmaExtenderItemList },
    { 0, 0 } //end of list
};
