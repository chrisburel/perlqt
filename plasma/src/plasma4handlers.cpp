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

extern void marshall_QHashQStringQVariant(Marshall *m);

TypeHandler Plasma4_handlers[] = {
    { "QHash<QString,QVariant>", marshall_QHashQStringQVariant },
    { "QHash<QString,QVariant>&", marshall_QHashQStringQVariant },
    { "const Plasma::DataEngine::Data", marshall_QHashQStringQVariant },
    { "const Plasma::DataEngine::Data&", marshall_QHashQStringQVariant },
    { 0, 0 } //end of list
};
