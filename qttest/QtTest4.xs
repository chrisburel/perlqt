/***************************************************************************
                          QtTest4.xs  -  QtTest perl extension
                             -------------------
    begin                : 07-12-2009
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

#include <smoke/qttest_smoke.h>

#include <smokeperl.h>
#include <handlers.h>

extern QList<Smoke*> smokeList;

const char*
resolve_classname_qttest(smokeperl_object * o)
{
    return perlqt_modules[o->smoke].binding->className(o->classId);
}

extern TypeHandler QtTest4_handlers[];

static PerlQt4::Binding bindingtest;

MODULE = QtTest4            PACKAGE = QtTest4::_internal

PROTOTYPES: DISABLE

SV*
getClassList()
    CODE:
        AV* classList = newAV();
        for (int i = 1; i < qttest_Smoke->numClasses; i++) {
            if (qttest_Smoke->classes[i].className && !qttest_Smoke->classes[i].external)
                av_push(classList, newSVpv(qttest_Smoke->classes[i].className, 0));
        }
        RETVAL = newRV_noinc((SV*)classList);
    OUTPUT:
        RETVAL

MODULE = QtTest4            PACKAGE = QtTest4

PROTOTYPES: ENABLE

BOOT:
    init_qttest_Smoke();
    smokeList << qttest_Smoke;

    bindingtest = PerlQt4::Binding(qttest_Smoke);

    PerlQt4Module module = { "PerlQtTest4", resolve_classname_qttest, 0, &bindingtest  };
    perlqt_modules[qttest_Smoke] = module;

    install_handlers(QtTest4_handlers);
