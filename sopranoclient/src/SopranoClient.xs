/***************************************************************************
                          SopranoClient.xs  -  SopranoClient perl extension
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

#include <smoke/sopranoclient_smoke.h>

#include <smokeperl.h>
#include <handlers.h>

extern QList<Smoke*> smokeList;
extern SV* sv_this;

const char*
resolve_classname_sopranoclient(smokeperl_object * o)
{
    return perlqt_modules[o->smoke].binding->className(o->classId);
}

extern TypeHandler SopranoClient_handlers[];

static PerlQt4::Binding bindingsopranoclient;

MODULE = SopranoClient            PACKAGE = SopranoClient::_internal

PROTOTYPES: DISABLE

SV*
getClassList()
    CODE:
        AV* classList = newAV();
        for (int i = 1; i < sopranoclient_Smoke->numClasses; i++) {
            if (sopranoclient_Smoke->classes[i].className && !sopranoclient_Smoke->classes[i].external)
                av_push(classList, newSVpv(sopranoclient_Smoke->classes[i].className, 0));
        }
        RETVAL = newRV_noinc((SV*)classList);
    OUTPUT:
        RETVAL

SV*
getEnumList()
    CODE:
        AV *av = newAV();
        for(int i = 1; i < sopranoclient_Smoke->numTypes; i++) {
            Smoke::Type curType = sopranoclient_Smoke->types[i];
            if( (curType.flags & Smoke::tf_elem) == Smoke::t_enum )
                av_push(av, newSVpv(curType.name, 0));
        }
        RETVAL = newRV_noinc((SV*)av);
    OUTPUT:
        RETVAL

MODULE = SopranoClient            PACKAGE = SopranoClient

PROTOTYPES: ENABLE

BOOT:
    init_sopranoclient_Smoke();
    smokeList << sopranoclient_Smoke;

    bindingsopranoclient = PerlQt4::Binding(sopranoclient_Smoke);

    PerlQt4Module module = { "PerlSopranoClient", resolve_classname_sopranoclient, 0, &bindingsopranoclient  };
    perlqt_modules[sopranoclient_Smoke] = module;

    install_handlers(SopranoClient_handlers);