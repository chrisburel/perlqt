/***************************************************************************
                          KIO4.xs  -  KIO perl extension
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

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
}

#include <smoke/kio_smoke.h>

#include <smokeperl.h>
#include <handlers.h>

extern QList<Smoke*> smokeList;

const char*
resolve_classname_kio(smokeperl_object * o)
{
    return perlqt_modules[o->smoke].binding->className(o->classId);
}

extern TypeHandler KIO4_handlers[];

static PerlQt4::Binding bindingkio;

MODULE = KIO4            PACKAGE = KIO4::_internal

PROTOTYPES: DISABLE

SV*
getClassList()
    CODE:
        AV* classList = newAV();
        for (int i = 1; i < kio_Smoke->numClasses; i++) {
            if (kio_Smoke->classes[i].className && !kio_Smoke->classes[i].external)
                av_push(classList, newSVpv(kio_Smoke->classes[i].className, 0));
        }
        RETVAL = newRV_noinc((SV*)classList);
    OUTPUT:
        RETVAL

SV*
getEnumList()
    CODE:
        AV *av = newAV();
        for(int i = 1; i < kio_Smoke->numTypes; i++) {
            Smoke::Type curType = kio_Smoke->types[i];
            if( (curType.flags & Smoke::tf_elem) == Smoke::t_enum )
                av_push(av, newSVpv(curType.name, 0));
        }
        RETVAL = newRV_noinc((SV*)av);
    OUTPUT:
        RETVAL

MODULE = KIO4            PACKAGE = KIO4

PROTOTYPES: ENABLE

BOOT:
    init_kio_Smoke();
    smokeList << kio_Smoke;

    bindingkio = PerlQt4::Binding(kio_Smoke);

    PerlQt4Module module = { "PerlKIO4", resolve_classname_kio, 0, &bindingkio  };
    perlqt_modules[kio_Smoke] = module;

    install_handlers(KIO4_handlers);
