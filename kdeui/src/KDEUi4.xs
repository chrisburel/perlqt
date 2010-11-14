/***************************************************************************
                          KDEUi4.xs  -  KDEUi perl extension
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

#include <smoke/kdeui_smoke.h>

#include <smokeperl.h>
#include <handlers.h>

extern QList<Smoke*> smokeList;
SV* sv_kapp = 0;

const char*
resolve_classname_kdeui(smokeperl_object * o)
{
    return perlqt_modules[o->smoke].binding->className(o->classId);
}

extern TypeHandler KDEUi4_handlers[];

static PerlQt4::Binding bindingkdeui;

MODULE = KDEUi4            PACKAGE = KDEUi4::_internal

PROTOTYPES: DISABLE

SV*
getClassList()
    CODE:
        AV* classList = newAV();
        for (int i = 1; i < kdeui_Smoke->numClasses; i++) {
            if (kdeui_Smoke->classes[i].className && !kdeui_Smoke->classes[i].external)
                av_push(classList, newSVpv(kdeui_Smoke->classes[i].className, 0));
        }
        RETVAL = newRV_noinc((SV*)classList);
    OUTPUT:
        RETVAL

SV*
getEnumList()
    CODE:
        AV *av = newAV();
        for(int i = 1; i < kdeui_Smoke->numTypes; i++) {
            Smoke::Type curType = kdeui_Smoke->types[i];
            if( (curType.flags & Smoke::tf_elem) == Smoke::t_enum )
                av_push(av, newSVpv(curType.name, 0));
        }
        RETVAL = newRV_noinc((SV*)av);
    OUTPUT:
        RETVAL

void
setKApp( kapp )
        SV* kapp
    CODE:
        if( SvROK( kapp ) )
            sv_setsv_mg( sv_kapp, kapp );

MODULE = KDEUi4            PACKAGE = KDEUi4

PROTOTYPES: ENABLE

SV*
kapp()
    CODE:
        if (!sv_kapp)
            RETVAL = &PL_sv_undef;
        else
            RETVAL = newSVsv(sv_kapp);
    OUTPUT:
        RETVAL

BOOT:
    init_kdeui_Smoke();
    smokeList << kdeui_Smoke;

    bindingkdeui = PerlQt4::Binding(kdeui_Smoke);

    PerlQt4Module module = { "PerlKDEUi4", resolve_classname_kdeui, 0, &bindingkdeui  };
    perlqt_modules[kdeui_Smoke] = module;

    install_handlers(KDEUi4_handlers);

    sv_kapp = newSV(0);
