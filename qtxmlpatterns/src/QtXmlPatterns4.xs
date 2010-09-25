/***************************************************************************
                          QtXmlPatterns4.xs  -  QtXmlPatterns perl extension
                             -------------------
    begin                : 06-19-2010
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

#include <smoke/qtxmlpatterns_smoke.h>

#include <smokeperl.h>
#include <handlers.h>

extern QList<Smoke*> smokeList;

const char*
resolve_classname_qtxmlpatterns(smokeperl_object * o)
{
    return perlqt_modules[o->smoke].binding->className(o->classId);
}

extern TypeHandler QtXmlPatterns4_handlers[];

static PerlQt4::Binding bindingqtxmlpatterns;

MODULE = QtXmlPatterns4            PACKAGE = QtXmlPatterns4::_internal

PROTOTYPES: DISABLE

SV*
getClassList()
    CODE:
        AV* classList = newAV();
        for (int i = 1; i <= qtxmlpatterns_Smoke->numClasses; i++) {
            if (qtxmlpatterns_Smoke->classes[i].className && !qtxmlpatterns_Smoke->classes[i].external)
                av_push(classList, newSVpv(qtxmlpatterns_Smoke->classes[i].className, 0));
        }
        RETVAL = newRV_noinc((SV*)classList);
    OUTPUT:
        RETVAL

SV*
getEnumList()
    CODE:
        AV *av = newAV();
        for(int i = 1; i < qtxmlpatterns_Smoke->numTypes; i++) {
            Smoke::Type curType = qtxmlpatterns_Smoke->types[i];
            if( (curType.flags & Smoke::tf_elem) == Smoke::t_enum )
                av_push(av, newSVpv(curType.name, 0));
        }
        RETVAL = newRV_noinc((SV*)av);
    OUTPUT:
        RETVAL

MODULE = QtXmlPatterns4            PACKAGE = QtXmlPatterns4

PROTOTYPES: ENABLE

BOOT:
    init_qtxmlpatterns_Smoke();
    smokeList << qtxmlpatterns_Smoke;

    bindingqtxmlpatterns = PerlQt4::Binding(qtxmlpatterns_Smoke);

    PerlQt4Module module = { "PerlQtXmlPatterns4", resolve_classname_qtxmlpatterns, 0, &bindingqtxmlpatterns  };
    perlqt_modules[qtxmlpatterns_Smoke] = module;

    install_handlers(QtXmlPatterns4_handlers);
