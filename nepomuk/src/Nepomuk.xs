/***************************************************************************
                          Nepomuk.xs  -  Nepomuk perl extension
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

#include <smoke/kde/nepomuk_smoke.h>

#include <smokeperl.h>
#include <handlers.h>

extern QList<Smoke*> smokeList;
extern SV* sv_this;

const char*
resolve_classname_nepomuk(smokeperl_object * o)
{
    return perlqt_modules[o->smoke].binding->className(o->classId);
}

extern TypeHandler Nepomuk_handlers[];

static PerlQt4::Binding bindingnepomuk;

MODULE = Nepomuk            PACKAGE = Nepomuk::_internal

PROTOTYPES: DISABLE

SV*
getClassList()
    CODE:
        AV* classList = newAV();
        for (int i = 1; i < nepomuk_Smoke->numClasses; i++) {
            if (nepomuk_Smoke->classes[i].className && !nepomuk_Smoke->classes[i].external)
                av_push(classList, newSVpv(nepomuk_Smoke->classes[i].className, 0));
        }
        RETVAL = newRV_noinc((SV*)classList);
    OUTPUT:
        RETVAL

SV*
getEnumList()
    CODE:
        AV *av = newAV();
        for(int i = 1; i < nepomuk_Smoke->numTypes; i++) {
            Smoke::Type curType = nepomuk_Smoke->types[i];
            if( (curType.flags & Smoke::tf_elem) == Smoke::t_enum )
                av_push(av, newSVpv(curType.name, 0));
        }
        RETVAL = newRV_noinc((SV*)av);
    OUTPUT:
        RETVAL

MODULE = Nepomuk            PACKAGE = Nepomuk

PROTOTYPES: ENABLE

BOOT:
    init_nepomuk_Smoke();
    smokeList << nepomuk_Smoke;

    bindingnepomuk = PerlQt4::Binding(nepomuk_Smoke);

    PerlQt4Module module = { "PerlNepomuk", resolve_classname_nepomuk, 0, &bindingnepomuk  };
    perlqt_modules[nepomuk_Smoke] = module;

    install_handlers(Nepomuk_handlers);
