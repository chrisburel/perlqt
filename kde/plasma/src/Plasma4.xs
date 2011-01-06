/***************************************************************************
                          Plasma4.xs  -  Plasma perl extension
                             -------------------
    begin                : 04-02-2010
    copyright            : (C) 2010 by Chris Burel
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

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
}

#include <plasma_smoke.h>

#include <smokeperl.h>
#include <handlers.h>

extern QList<Smoke*> smokeList;

const char*
resolve_classname_plasma(smokeperl_object * o)
{
    return perlqt_modules[o->smoke].binding->className(o->classId);
}

extern TypeHandler Plasma4_handlers[];

static PerlQt4::Binding bindingplasma;

MODULE = Plasma4            PACKAGE = Plasma4::_internal

PROTOTYPES: DISABLE

SV*
getClassList()
    CODE:
        AV* classList = newAV();
        for (int i = 1; i < plasma_Smoke->numClasses; i++) {
            if (plasma_Smoke->classes[i].className && !plasma_Smoke->classes[i].external)
                av_push(classList, newSVpv(plasma_Smoke->classes[i].className, 0));
        }
        RETVAL = newRV_noinc((SV*)classList);
    OUTPUT:
        RETVAL

SV*
getEnumList()
    CODE:
        AV *av = newAV();
        for(int i = 1; i < plasma_Smoke->numTypes; i++) {
            Smoke::Type curType = plasma_Smoke->types[i];
            if( (curType.flags & Smoke::tf_elem) == Smoke::t_enum )
                av_push(av, newSVpv(curType.name, 0));
        }
        RETVAL = newRV_noinc((SV*)av);
    OUTPUT:
        RETVAL

MODULE = Plasma4            PACKAGE = Plasma4

PROTOTYPES: ENABLE

BOOT:
    init_plasma_Smoke();
    smokeList << plasma_Smoke;

    bindingplasma = PerlQt4::Binding(plasma_Smoke);

    PerlQt4Module module = { "PerlPlasma4", resolve_classname_plasma, 0, &bindingplasma  };
    perlqt_modules[plasma_Smoke] = module;

    install_handlers(Plasma4_handlers);
