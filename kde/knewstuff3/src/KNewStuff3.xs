/***************************************************************************
                          KNewStuff3.xs  -  KNewStuff3 perl extension
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

#include <knewstuff3_smoke.h>

#include <smokeperl.h>
#include <handlers.h>

extern QList<Smoke*> smokeList;
extern SV* sv_this;

const char*
resolve_classname_knewstuff3(smokeperl_object * o)
{
    return perlqt_modules[o->smoke].binding->className(o->classId);
}

extern TypeHandler KNewStuff3_handlers[];

static PerlQt4::Binding bindingknewstuff3;

MODULE = KNewStuff3            PACKAGE = KNewStuff3::_internal

PROTOTYPES: DISABLE

SV*
getClassList()
    CODE:
        AV* classList = newAV();
        for (int i = 1; i < knewstuff3_Smoke->numClasses; i++) {
            if (knewstuff3_Smoke->classes[i].className && !knewstuff3_Smoke->classes[i].external)
                av_push(classList, newSVpv(knewstuff3_Smoke->classes[i].className, 0));
        }
        RETVAL = newRV_noinc((SV*)classList);
    OUTPUT:
        RETVAL

SV*
getEnumList()
    CODE:
        AV *av = newAV();
        for(int i = 1; i < knewstuff3_Smoke->numTypes; i++) {
            Smoke::Type curType = knewstuff3_Smoke->types[i];
            if( (curType.flags & Smoke::tf_elem) == Smoke::t_enum )
                av_push(av, newSVpv(curType.name, 0));
        }
        RETVAL = newRV_noinc((SV*)av);
    OUTPUT:
        RETVAL

MODULE = KNewStuff3            PACKAGE = KNewStuff3

PROTOTYPES: ENABLE

BOOT:
    init_knewstuff3_Smoke();
    smokeList << knewstuff3_Smoke;

    bindingknewstuff3 = PerlQt4::Binding(knewstuff3_Smoke);

    PerlQt4Module module = { "PerlKNewStuff3", resolve_classname_knewstuff3, 0, &bindingknewstuff3  };
    perlqt_modules[knewstuff3_Smoke] = module;

    install_handlers(KNewStuff3_handlers);
