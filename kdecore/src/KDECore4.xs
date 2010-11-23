/***************************************************************************
                          KDECore4.xs  -  KDECore perl extension
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

#include <smoke/kdecore_smoke.h>

#include <smokeperl.h>
#include <handlers.h>

extern QList<Smoke*> smokeList;

const char*
resolve_classname_kdecore(smokeperl_object * o)
{
    return perlqt_modules[o->smoke].binding->className(o->classId);
}

extern TypeHandler KDECore4_handlers[];

static PerlQt4::Binding bindingkdecore;

MODULE = KDECore4            PACKAGE = KDECore4::_internal

PROTOTYPES: DISABLE

SV*
getClassList()
    CODE:
        AV* classList = newAV();
        for (int i = 1; i < kdecore_Smoke->numClasses; i++) {
            if (kdecore_Smoke->classes[i].className && !kdecore_Smoke->classes[i].external)
                av_push(classList, newSVpv(kdecore_Smoke->classes[i].className, 0));
        }
        RETVAL = newRV_noinc((SV*)classList);
    OUTPUT:
        RETVAL

SV*
getEnumList()
    CODE:
        AV *av = newAV();
        for(int i = 1; i < kdecore_Smoke->numTypes; i++) {
            Smoke::Type curType = kdecore_Smoke->types[i];
            if( (curType.flags & Smoke::tf_elem) == Smoke::t_enum )
                av_push(av, newSVpv(curType.name, 0));
        }
        RETVAL = newRV_noinc((SV*)av);
    OUTPUT:
        RETVAL

MODULE = KDECore4            PACKAGE = KDECore4

PROTOTYPES: ENABLE

BOOT:
    init_kdecore_Smoke();
    smokeList << kdecore_Smoke;

    bindingkdecore = PerlQt4::Binding(kdecore_Smoke);

    PerlQt4Module module = { "PerlKDECore4", resolve_classname_kdecore, 0, &bindingkdecore  };
    perlqt_modules[kdecore_Smoke] = module;

    install_handlers(KDECore4_handlers);
