/***************************************************************************
                          QtGui4.xs  -  QtGui perl extension
                             -------------------
    begin                : 03-29-2010
    copyright            : (C) 2009 by Chris Burel
    email                : chrisburel@gmail.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#include <QHash>
#include <QList>
#include <QtDebug>

#include <iostream>

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
}

#include <smoke/qtgui_smoke.h>

#include <smokeperl.h>
#include <handlers.h>

extern QList<Smoke*> smokeList;

const char*
resolve_classname_qtgui(smokeperl_object * o)
{
    return perlqt_modules[o->smoke].binding->className(o->classId);
}

extern TypeHandler QtGui4_handlers[];

static PerlQt4::Binding bindingqtgui;

MODULE = QtGui4            PACKAGE = QtGui4::_internal

PROTOTYPES: DISABLE

SV*
getClassList()
    CODE:
        AV* classList = newAV();
        for (int i = 1; i < qtgui_Smoke->numClasses; i++) {
            if (qtgui_Smoke->classes[i].className && !qtgui_Smoke->classes[i].external)
                av_push(classList, newSVpv(qtgui_Smoke->classes[i].className, 0));
        }
        RETVAL = newRV_noinc((SV*)classList);
    OUTPUT:
        RETVAL

#// args: none
#// returns: an array of all enum names that qtgui_Smoke knows about
SV*
getEnumList()
    CODE:
        AV *av = newAV();
        for(int i = 1; i < qtgui_Smoke->numTypes; i++) {
            Smoke::Type curType = qtgui_Smoke->types[i];
            if( (curType.flags & Smoke::tf_elem) == Smoke::t_enum )
                av_push(av, newSVpv(curType.name, 0));
        }
        RETVAL = newRV_noinc((SV*)av);
    OUTPUT:
        RETVAL

MODULE = QtGui4            PACKAGE = QtGui4

PROTOTYPES: ENABLE

BOOT:
    init_qtgui_Smoke();
    smokeList << qtgui_Smoke;

    bindingqtgui = PerlQt4::Binding(qtgui_Smoke);

    PerlQt4Module module = { "PerlQtGui4", resolve_classname_qtgui, 0, &bindingqtgui  };
    perlqt_modules[qtgui_Smoke] = module;

    install_handlers(QtGui4_handlers);
