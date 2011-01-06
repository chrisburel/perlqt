/***************************************************************************
                          Kate.xs  -  Kate perl extension
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

#include <kate_smoke.h>

#include <smokeperl.h>
#include <handlers.h>

extern QList<Smoke*> smokeList;
extern SV* sv_this;

const char*
resolve_classname_kate(smokeperl_object * o)
{
    return perlqt_modules[o->smoke].binding->className(o->classId);
}

extern TypeHandler Kate_handlers[];

static PerlQt4::Binding bindingkate;

MODULE = Kate            PACKAGE = Kate::_internal

PROTOTYPES: DISABLE

SV*
getClassList()
    CODE:
        AV* classList = newAV();
        for (int i = 1; i < kate_Smoke->numClasses; i++) {
            if (kate_Smoke->classes[i].className && !kate_Smoke->classes[i].external)
                av_push(classList, newSVpv(kate_Smoke->classes[i].className, 0));
        }
        RETVAL = newRV_noinc((SV*)classList);
    OUTPUT:
        RETVAL

SV*
getEnumList()
    CODE:
        AV *av = newAV();
        for(int i = 1; i < kate_Smoke->numTypes; i++) {
            Smoke::Type curType = kate_Smoke->types[i];
            if( (curType.flags & Smoke::tf_elem) == Smoke::t_enum )
                av_push(av, newSVpv(curType.name, 0));
        }
        RETVAL = newRV_noinc((SV*)av);
    OUTPUT:
        RETVAL

MODULE = Kate            PACKAGE = Kate

PROTOTYPES: ENABLE

BOOT:
    init_kate_Smoke();
    smokeList << kate_Smoke;

    bindingkate = PerlQt4::Binding(kate_Smoke);

    PerlQt4Module module = { "PerlKate", resolve_classname_kate, 0, &bindingkate  };
    perlqt_modules[kate_Smoke] = module;

    install_handlers(Kate_handlers);
