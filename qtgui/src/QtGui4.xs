/***************************************************************************
                          QtGui4.xs  -  QtGui perl extension
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
#include <QtDebug>
#include <QPolygonF>
#include <QPointF>
#include <QVector>
#include <QtGui/QAbstractProxyModel>
#include <QtGui/QSortFilterProxyModel>
#include <QtGui/QDirModel>
#include <QtGui/QFileSystemModel>
#include <QtGui/QProxyModel>
#include <QtGui/QStandardItemModel>
#include <QtGui/QStringListModel>

#include <iostream>

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
}

#include <smoke/qtgui_smoke.h>

#include <smokeperl.h>
#include <handlers.h>
#include <util.h>

extern QList<Smoke*> smokeList;
extern SV* sv_this;

const char*
resolve_classname_qtgui(smokeperl_object * o)
{
    return perlqt_modules[o->smoke].binding->className(o->classId);
}

extern TypeHandler QtGui4_handlers[];

static PerlQt4::Binding bindingqtgui;

MODULE = QtGui4            PACKAGE = Qt::PolygonF
PROTOTYPES: DISABLE

SV*
at( index )
        int index
    CODE:
        smokeperl_object* o = sv_obj_info(sv_this);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        QPolygonF* polygon = (QPolygonF*)o->ptr;
        if ( 0 > index || index > polygon->size() - 1 )
            XSRETURN_UNDEF;
        QPointF* point = new QPointF(polygon->at(index));
        Smoke::ModuleIndex mi = Smoke::classMap["QPointF"];
        smokeperl_object* reto = alloc_smokeperl_object(
            true, mi.smoke, mi.index, (void*)point );
        const char* classname = perlqt_modules[reto->smoke].resolve_classname(reto);
        RETVAL = set_obj_info( classname, reto );
    OUTPUT:
        RETVAL

bool
exists( index )
        int index
    CODE:
        smokeperl_object* o = sv_obj_info(sv_this);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        QPolygonF* polygon = (QPolygonF*)o->ptr;
        if ( 0 > index || index > polygon->size() - 1 )
            RETVAL = false;
        else
            RETVAL = true;
    OUTPUT:
        RETVAL

int
size()
    CODE:
        smokeperl_object* o = sv_obj_info(sv_this);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        QPolygonF* polygon = (QPolygonF*)o->ptr;
        RETVAL = polygon->size();
    OUTPUT:
        RETVAL

SV*
store( index, value )
        int index
        SV* value
    CODE:
        smokeperl_object* o = sv_obj_info(sv_this);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        smokeperl_object* valueo = sv_obj_info(value);
        if (!valueo || !valueo->ptr)
            XSRETURN_UNDEF;
        QPolygonF* polygon = (QPolygonF*)o->ptr;
        QPointF* point = (QPointF*)valueo->ptr;

        if ( 0 > index )
            XSRETURN_UNDEF;
        else if ( index > polygon->size() )
            XSRETURN_UNDEF;
        else if ( index == polygon->size() )
            polygon->append( *point );
        else
            polygon->replace( index, *point );
        RETVAL = value;
    OUTPUT:
        RETVAL

MODULE = QtGui4            PACKAGE = QtGui4::_internal

PROTOTYPES: DISABLE

SV*
getClassList()
    CODE:
        AV* classList = newAV();
        for (int i = 1; i < qtgui_Smoke->numClasses; i++) {
            if (qtgui_Smoke->classes[i].className && !qtgui_Smoke->classes[i].external)
                av_push(classList, newSVpv(qtgui_Smoke->classes[i].className, 0));
        }
        RETVAL = newRV_noinc((SV*)classList);
    OUTPUT:
        RETVAL

#// args: none
#// returns: an array of all enum names that qtgui_Smoke knows about
SV*
getEnumList()
    CODE:
        AV *av = newAV();
        for(int i = 1; i < qtgui_Smoke->numTypes; i++) {
            Smoke::Type curType = qtgui_Smoke->types[i];
            if( (curType.flags & Smoke::tf_elem) == Smoke::t_enum )
                av_push(av, newSVpv(curType.name, 0));
        }
        RETVAL = newRV_noinc((SV*)av);
    OUTPUT:
        RETVAL

MODULE = QtGui4            PACKAGE = QtGui4

PROTOTYPES: ENABLE

BOOT:
    init_qtgui_Smoke();
    smokeList << qtgui_Smoke;

    bindingqtgui = PerlQt4::Binding(qtgui_Smoke);

    PerlQt4Module module = { "PerlQtGui4", resolve_classname_qtgui, 0, &bindingqtgui  };
    perlqt_modules[qtgui_Smoke] = module;

    install_handlers(QtGui4_handlers);

