/***************************************************************************
                          Solid.xs  -  Solid perl extension
                             -------------------
    begin                : 11-14-2010
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

#include <solid_smoke.h>

#include <smokeperl.h>
#include <handlers.h>

extern QList<Smoke*> smokeList;
extern SV* sv_this;

const char*
resolve_classname_solid(smokeperl_object * o)
{
    return perlqt_modules[o->smoke].binding->className(o->classId);
}

extern TypeHandler Solid_handlers[];

static PerlQt4::Binding bindingsolid;

MODULE = Solid            PACKAGE = Solid::_internal

PROTOTYPES: DISABLE

SV*
getClassList()
    CODE:
        AV* classList = newAV();
        for (int i = 1; i < solid_Smoke->numClasses; i++) {
            if (solid_Smoke->classes[i].className && !solid_Smoke->classes[i].external)
                av_push(classList, newSVpv(solid_Smoke->classes[i].className, 0));
        }
        RETVAL = newRV_noinc((SV*)classList);
    OUTPUT:
        RETVAL

SV*
getEnumList()
    CODE:
        AV *av = newAV();
        for(int i = 1; i < solid_Smoke->numTypes; i++) {
            Smoke::Type curType = solid_Smoke->types[i];
            if( (curType.flags & Smoke::tf_elem) == Smoke::t_enum )
                av_push(av, newSVpv(curType.name, 0));
        }
        RETVAL = newRV_noinc((SV*)av);
    OUTPUT:
        RETVAL

MODULE = Solid            PACKAGE = Solid

PROTOTYPES: ENABLE

BOOT:
    init_solid_Smoke();
    smokeList << solid_Smoke;

    bindingsolid = PerlQt4::Binding(solid_Smoke);

    PerlQt4Module module = { "PerlSolid", resolve_classname_solid, 0, &bindingsolid  };
    perlqt_modules[solid_Smoke] = module;

    install_handlers(Solid_handlers);
