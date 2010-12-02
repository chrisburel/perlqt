/***************************************************************************
                          KNewStuff2.xs  -  KNewStuff2 perl extension
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

#include <smoke/kde/knewstuff2_smoke.h>

#include <smokeperl.h>
#include <handlers.h>

extern QList<Smoke*> smokeList;
extern SV* sv_this;

const char*
resolve_classname_knewstuff2(smokeperl_object * o)
{
    return perlqt_modules[o->smoke].binding->className(o->classId);
}

extern TypeHandler KNewStuff2_handlers[];

static PerlQt4::Binding bindingknewstuff2;

MODULE = KNewStuff2            PACKAGE = KNewStuff2::_internal

PROTOTYPES: DISABLE

SV*
getClassList()
    CODE:
        AV* classList = newAV();
        for (int i = 1; i < knewstuff2_Smoke->numClasses; i++) {
            if (knewstuff2_Smoke->classes[i].className && !knewstuff2_Smoke->classes[i].external)
                av_push(classList, newSVpv(knewstuff2_Smoke->classes[i].className, 0));
        }
        RETVAL = newRV_noinc((SV*)classList);
    OUTPUT:
        RETVAL

SV*
getEnumList()
    CODE:
        AV *av = newAV();
        for(int i = 1; i < knewstuff2_Smoke->numTypes; i++) {
            Smoke::Type curType = knewstuff2_Smoke->types[i];
            if( (curType.flags & Smoke::tf_elem) == Smoke::t_enum )
                av_push(av, newSVpv(curType.name, 0));
        }
        RETVAL = newRV_noinc((SV*)av);
    OUTPUT:
        RETVAL

MODULE = KNewStuff2            PACKAGE = KNewStuff2

PROTOTYPES: ENABLE

BOOT:
    init_knewstuff2_Smoke();
    smokeList << knewstuff2_Smoke;

    bindingknewstuff2 = PerlQt4::Binding(knewstuff2_Smoke);

    PerlQt4Module module = { "PerlKNewStuff2", resolve_classname_knewstuff2, 0, &bindingknewstuff2  };
    perlqt_modules[knewstuff2_Smoke] = module;

    install_handlers(KNewStuff2_handlers);
