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

        if ( index > polygon->size() ) {
            polygon->resize( index );
        }
        polygon->append( *point );

        RETVAL = newSVsv(value);
    OUTPUT:
        RETVAL

AV*
storesize( count )
        int count
    PPCODE:
        smokeperl_object* o = sv_obj_info(sv_this);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        QPolygonF* polygon = (QPolygonF*)o->ptr;

        polygon->resize( count );

SV*
delete( index )
        int index
    CODE:
        smokeperl_object* o = sv_obj_info(sv_this);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        QPolygonF* polygon = (QPolygonF*)o->ptr;

        QPointF* point = new QPointF(polygon->at(index));

        polygon->replace( index, QPointF() );

        Smoke::ModuleIndex mi = Smoke::classMap["QPointF"];
        smokeperl_object* reto = alloc_smokeperl_object(
            true, mi.smoke, mi.index, (void*)point );
        const char* classname = perlqt_modules[reto->smoke].resolve_classname(reto);
        RETVAL = set_obj_info( classname, reto );
    OUTPUT:
        RETVAL

void
clear( )
    CODE:
        smokeperl_object* o = sv_obj_info(sv_this);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        QPolygonF* polygon = (QPolygonF*)o->ptr;

        polygon->resize(0);

int
push( ... )
    CODE:
        smokeperl_object* o = sv_obj_info(sv_this);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        QPolygonF* polygon = (QPolygonF*)o->ptr;

        for( int i = 0; i < items; ++i ) {
            smokeperl_object *arg = sv_obj_info(ST(i));
            if (!arg || !arg->ptr)
                continue;
            QPointF* point = (QPointF*)arg->ptr;
            polygon->append( *point );
        }
        RETVAL = polygon->size();
    OUTPUT:
        RETVAL

SV*
pop()
    CODE:
        smokeperl_object* o = sv_obj_info(sv_this);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        QPolygonF* polygon = (QPolygonF*)o->ptr;

        QPointF* point = new QPointF(polygon->last());
        Smoke::ModuleIndex mi = Smoke::classMap["QPointF"];
        smokeperl_object* reto = alloc_smokeperl_object(
            true, mi.smoke, mi.index, (void*)point );
        const char* classname = perlqt_modules[reto->smoke].resolve_classname(reto);
        RETVAL = set_obj_info( classname, reto );
        polygon->remove(polygon->size()-1);
    OUTPUT:
        RETVAL

SV*
shift()
    CODE:
        smokeperl_object* o = sv_obj_info(sv_this);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        QPolygonF* polygon = (QPolygonF*)o->ptr;

        QPointF* point = new QPointF(polygon->first());
        Smoke::ModuleIndex mi = Smoke::classMap["QPointF"];
        smokeperl_object* reto = alloc_smokeperl_object(
            true, mi.smoke, mi.index, (void*)point );
        const char* classname = perlqt_modules[reto->smoke].resolve_classname(reto);
        RETVAL = set_obj_info( classname, reto );
        polygon->remove(0);
    OUTPUT:
        RETVAL

int
unshift( ... )
    CODE:
        smokeperl_object* o = sv_obj_info(sv_this);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        QPolygonF* polygon = (QPolygonF*)o->ptr;

        for( int i = items-1; i >= 0; --i ) {
            smokeperl_object *arg = sv_obj_info(ST(i));
            if (!arg || !arg->ptr)
                continue;
            QPointF* point = (QPointF*)arg->ptr;
            polygon->insert( 0, *point );
        }
        RETVAL = polygon->size();
    OUTPUT:
        RETVAL

void
splice( firstIndex = 0, length = -1, ... )
        int firstIndex
        int length
    CODE:
        smokeperl_object* o = sv_obj_info(sv_this);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        QPolygonF* polygon = (QPolygonF*)o->ptr;

        if ( firstIndex > polygon->size() )
            firstIndex = polygon->size();

        if ( length == -1 )
            length = polygon->size()-firstIndex;

        int lastIndex = firstIndex + length;

        AV* args = newAV();
        for( int i = 2; i < items; ++i ) {
            av_push(args, ST(i));
        }

        EXTEND(SP, length);

        Smoke::ModuleIndex mi = Smoke::classMap["QPointF"];
        for( int i = firstIndex, j = 0; i < lastIndex; ++i, ++j ) {
            QPointF* point = new QPointF(polygon->at(firstIndex));

            smokeperl_object* reto = alloc_smokeperl_object(
                    true, mi.smoke, mi.index, (void*)point );
            const char* classname = perlqt_modules[reto->smoke].resolve_classname(reto);
            SV* retval = set_obj_info( classname, reto );
            point = (QPointF*)sv_obj_info(retval)->ptr;
            ST(j) = retval;
            polygon->remove(firstIndex);
        }

        for( int i = items-3; i >= 0; --i ) {
            QPointF* point = (QPointF*)(sv_obj_info(av_pop(args))->ptr);
            polygon->insert(firstIndex, *point);
        }

        XSRETURN( length );

MODULE = QtGui4            PACKAGE = Qt::PolygonF::_overload
PROTOTYPES: DISABLE

bool
op_equality( first, second, reversed )
        SV* first
        SV* second
    CODE:
        smokeperl_object* o1 = sv_obj_info(first);
        if (!o1 || !o1->ptr)
            XSRETURN_UNDEF;
        QPolygonF* polygon1 = (QPolygonF*)o1->ptr;

        smokeperl_object* o2 = sv_obj_info(second);
        if (!o2 || !o2->ptr || isDerivedFrom(o2, "QPolygonF") == -1)
            XSRETURN_UNDEF;
        QPolygonF* polygon2 = (QPolygonF*)o2->ptr;

        RETVAL = *polygon1 == *polygon2;
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

    newXS("Qt::PolygonF::EXISTS"   , XS_Qt__PolygonF_exists, __FILE__);
    newXS("Qt::PolygonF::FETCH"    , XS_Qt__PolygonF_at, __FILE__);
    newXS("Qt::PolygonF::FETCHSIZE", XS_Qt__PolygonF_size, __FILE__);
    newXS("Qt::PolygonF::STORE"    , XS_Qt__PolygonF_store, __FILE__);
    newXS("Qt::PolygonF::STORESIZE", XS_Qt__PolygonF_storesize, __FILE__);
    newXS("Qt::PolygonF::DELETE"   , XS_Qt__PolygonF_delete, __FILE__);
    newXS("Qt::PolygonF::CLEAR"    , XS_Qt__PolygonF_clear, __FILE__);
    newXS("Qt::PolygonF::PUSH"     , XS_Qt__PolygonF_push, __FILE__);
    newXS("Qt::PolygonF::POP"      , XS_Qt__PolygonF_pop, __FILE__);
    newXS("Qt::PolygonF::SHIFT"    , XS_Qt__PolygonF_shift, __FILE__);
    newXS("Qt::PolygonF::UNSHIFT"  , XS_Qt__PolygonF_unshift, __FILE__);
    newXS("Qt::PolygonF::SPLICE"   , XS_Qt__PolygonF_splice, __FILE__);
