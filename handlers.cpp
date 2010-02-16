/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#include <QtCore/qdir.h>
#include <QtCore/qhash.h>
#include <QtCore/qlinkedlist.h>
#include <QtCore/qmetaobject.h>
#include <QtCore/qobject.h>
#include <QtCore/qpair.h>
#include <QtCore/qprocess.h>
#include <QtCore/qregexp.h>
#include <QtCore/qstring.h>
#include <QtCore/qtextcodec.h>
#include <QtCore/qurl.h>
#include <QtGui/qabstractbutton.h>
#include <QtGui/qaction.h>
#include <QtGui/qapplication.h>
#include <QtGui/qdockwidget.h>
#include <QtGui/qevent.h>
#include <QtGui/qlayout.h>
#include <QtGui/qlistwidget.h>
#include <QtGui/qpainter.h>
#include <QtGui/qpalette.h>
#include <QtGui/qpixmap.h>
#include <QtGui/qpolygon.h>
#include <QtGui/qtabbar.h>
#include <QtGui/qtablewidget.h>
#include <QtGui/qtextedit.h>
#include <QtGui/qtextlayout.h>
#include <QtGui/qtextobject.h>
#include <QtGui/qtoolbar.h>
#include <QtGui/qtreewidget.h>
#include <QtGui/qwidget.h>
#include <QtNetwork/qhostaddress.h>
#include <QtNetwork/qnetworkinterface.h>
#include <QtNetwork/qurlinfo.h>


#if QT_VERSION >= 0x40200
#include <QtGui/qgraphicsitem.h>
#include <QtGui/qgraphicsscene.h>
#include <QtGui/qstandarditemmodel.h>
#include <QtGui/qundostack.h>
#endif

#if QT_VERSION >= 0x40300
#include <QtGui/qmdisubwindow.h>
#include <QtNetwork/qsslcertificate.h>
#include <QtNetwork/qsslcipher.h>
#include <QtNetwork/qsslerror.h>
#include <QtXml/qxmlstream.h>
#endif

#if QT_VERSION >= 0x040400
#include <QtGui/qprinterinfo.h>
#include <QtNetwork/qnetworkcookie.h>
#endif

//==============================================================================

#define UNTESTED_HANDLER(name) fprintf( stderr, "The handler %s has not been tested.\n", name );
#include "handlers.h"
#include "binding.h"
#include "Qt.h"
#include "marshall_basetypes.h"
#include "smokeperl.h"
#include "smokehelp.h"

HV *type_handlers = 0;

struct mgvtbl vtbl_smoke = { 0, 0, 0, 0, smokeperl_free };

int smokeperl_free(pTHX_ SV* sv, MAGIC* mg) {
    smokeperl_object* o = (smokeperl_object*)mg->mg_ptr;
    if (o->allocated && o->ptr) {
        invoke_dtor( o );
    }
    return 0;
}

void invoke_dtor(smokeperl_object* o) {
    Smoke::Index methodId = 0;
    if ( methodId ) { // Cache lookup
    }
    else {
        const char* className = o->smoke->classes[o->classId].className;
        char* methodName = new char[strlen(className) + 2];
        methodName[0] = '~';
        strcpy(methodName + 1, className);
        Smoke::Index method = o->smoke->findMethod( className, methodName ).index;
        if (method > 0) {
            Smoke::Method& m = o->smoke->methods[o->smoke->methodMaps[method].method];
            Smoke::ClassFn fn = o->smoke->classes[m.classId].classFn;
            Smoke::StackItem i[1];
            (*fn)(m.method, o->ptr, i);
        }
        delete [] methodName;
    }
}

template <class T>
static void marshall_it(Marshall* m) {
    switch( m->action() ) {
        case Marshall::FromSV:
            marshall_from_perl<T>( m );
        break;

        case Marshall::ToSV:
            marshall_to_perl<T>( m );
        break;

        default:
            m->unsupported();
        break;
    }
}

QString* qstringFromPerlString( SV* perlstring ) {
    // Finally found how 'in_constructor' is being used
    // PerlQt3 has this bizness:
    // COP *cop = in_constructor ? cxstack[cxstack_ix-3].blk_oldcop : cxstack[cxstack_ix].blk_oldcop;
    // It looks like the 'cxstack' array can be used to look at the current
    // call stack.  If 'in_constructor' is set, we need to look farther up the
    // call stack to find the correct caller.
    // Forget that crap for now.
    // What's blk_oldcop?
    COP *cop = cxstack[cxstack_ix].blk_oldcop;
    if ( SvUTF8( perlstring ) )
        return new QString(QString::fromUtf8(SvPV_nolen(perlstring)));
    else if ( cop->op_private & HINT_LOCALE )
        return new QString(QString::fromLocal8Bit(SvPV_nolen(perlstring)));
    else
        return new QString(QString::fromLatin1(SvPV_nolen(perlstring)));
}

SV* perlstringFromQString( QString * s ) {
    SV *retval = newSV(0);
    COP *cop = cxstack[cxstack_ix].blk_oldcop;
    if ( !(cop->op_private & HINT_BYTES ) ) {
        sv_setpv( retval, (const char *)s->toUtf8() );
        SvUTF8_on( retval );
    }
    else if ( cop->op_private & HINT_LOCALE )
        sv_setpv( retval, (const char *)s->toLocal8Bit() );
    else
        sv_setpv( retval, (const char *)s->toLatin1() );

    return retval;
}

void marshall_basetype(Marshall* m) {
    switch( m->type().elem() ) {

        case Smoke::t_bool:
            marshall_it<bool>(m);
        break;
/*
        case Smoke::t_char:
            marshall_it<signed char>(m);
        break;

        case Smoke::t_uchar:
            marshall_it<unsigned char>(m);
        break;

        case Smoke::t_short:
            marshall_it<short>(m);
        break;

        case Smoke::t_ushort:
            marshall_it<unsigned short>(m);
        break;
*/
        case Smoke::t_int:
            marshall_it<int>(m);
        break;

        case Smoke::t_uint:
            marshall_it<unsigned int>(m);
        break;
/*
        case Smoke::t_long:
            marshall_it<long>(m);
        break;

        case Smoke::t_ulong:
            marshall_it<unsigned long>(m);
        break;

        case Smoke::t_float:
            marshall_it<float>(m);
        break;
*/
        case Smoke::t_double:
            marshall_it<double>(m);
        break;

        case Smoke::t_enum:
            switch(m->action()) {
                case Marshall::FromSV:
                    if( !SvROK(m->var()) ) {
                        die( "Corrupt enum value\n" );
                    }
                    else {
                        m->item().s_enum = (long)SvIV(SvRV(m->var()));
                    }
                break;
                case Marshall::ToSV: {
                    // Bless the enum value to a package named the same as the
                    // enum name
                    SV* rv = newRV_noinc(newSViv((IV)m->item().s_enum));
                    sv_bless( rv, gv_stashpv(m->type().name(), TRUE) );
                    sv_setsv_mg(m->var(), rv);
                }
                break;
            }
        break;

        case Smoke::t_class:
            switch( m->action() ) {
                case Marshall::FromSV: {
                    smokeperl_object* o = sv_obj_info( m->var() );
                    if( !o || !o->ptr ) {
                        if( m->type().isRef() ) {
                            warn( "References can't be null or undef\n");
                            m->unsupported();
                        }
                        m->item().s_class = 0;
                        break;
                    }

                    void* ptr = o->ptr;

                    if( !m->cleanup() && m->type().isStack()) {
                        fprintf( stderr, "Should construct copy in handler\n" );
                    }

                    const Smoke::Class& c = m->smoke()->classes[m->type().classId()];
                    ptr = o->smoke->cast(
                        ptr,
                        o->classId,
                        o->smoke->idClass(c.className).index
                    );

                    m->item().s_voidp = ptr;
                }
                break;
                case Marshall::ToSV: {
                    if ( !m->item().s_voidp ) {
                        SvSetMagicSV(m->var(), &PL_sv_undef);
                        return;
                    }

                    // Get return value
                    void* cxxptr = m->item().s_voidp;

                    // See if we already made a perl object for this pointer
                    SV* var = getPointerObject(cxxptr);
                    if (var) {
                        SvSetMagicSV(m->var(), var);
                        break;
                    }

                    var = allocSmokePerlSV( cxxptr, m->type() );

                    // Copy our local var into the marshaller's var, and make
                    // sure to copy our magic with it
                    SvSetMagicSV(m->var(), var);
                }
            }
        break;

        default:
            return marshall_unknown( m );
        break;
    }
}

void marshall_void(Marshall *) {}
void marshall_unknown(Marshall *m) {
    m->unsupported();
}
/*
void marshall_ucharP(Marshall *m) {
    UNTESTED_HANDLER("marshall_ucharP");
    marshall_it<unsigned char *>(m);
}
*/
static void marshall_doubleR(Marshall *m) {
    UNTESTED_HANDLER("marshall_doubleR");
    switch(m->action()) {
        case Marshall::FromSV: {
            SV *rv = m->var();
            double * d = new double;
            *d = SvNV(rv);
            m->item().s_voidp = d;
            m->next();
            if (m->cleanup() && m->type().isConst()) {
                delete d;
            } else {
                m->item().s_voidp = new double((double)SvNV(rv));
            }
        }
        break;
        case Marshall::ToSV: {
            double *dp = (double*)m->item().s_voidp;
            SV *rv = m->var();
            if (dp == 0) {
                sv_setsv( rv, &PL_sv_undef );
                break;
            }
            sv_setnv(m->var(), *dp);
            m->next();
            if (!m->type().isConst()) {
                *dp = SvNV(m->var());
            }
        }
        break;
        default:
            m->unsupported();
        break;
    }
}

void marshall_QString(Marshall* m) {
    switch(m->action()) {
      case Marshall::FromSV: {
            SV* sv = m->var();
            QString* mystr = 0;
            if( SvOK(sv) ) {
                mystr = qstringFromPerlString( sv );
            }
            else {
                mystr = new QString();
            }

            m->item().s_voidp = (void*)mystr;
            m->next();

            if ( mystr != 0 && m->cleanup() ) {
                delete mystr;
            }
        }
        break;
      case Marshall::ToSV: {
            QString* cxxptr = (QString*)m->item().s_voidp;
            if( cxxptr ) {
                if (cxxptr->isNull()) {
                    sv_setsv( m->var(), &PL_sv_undef );
                }
                else {
                    sv_setsv( m->var(), perlstringFromQString( cxxptr ) );
                }

                if (m->cleanup() || m->type().isStack() ) {
                    delete cxxptr;
                }
            }
            else {
                sv_setsv( m->var(), &PL_sv_undef );
            }
        }
        break;
      default:
        m->unsupported();
        break;
    }
}

/*
static void marshall_QByteArray(Marshall *m) {
    UNTESTED_HANDLER("marshall_QByteArray");
  switch(m->action()) {
    case Marshall::FromSV:
    {
      QByteArray* s = 0;
      if( *(m->var()) != Qnil) {
        s = qbytearrayFromRString(*(m->var()));
      } else {
        s = new QByteArray();
      }

      m->item().s_voidp = s;
      m->next();

      if (!m->type().isConst() && *(m->var()) != Qnil && s != 0 && !s->isNull()) {
        rb_str_resize(*(m->var()), 0);
        VALUE temp = rstringFromQByteArray(s);
        rb_str_cat2(*(m->var()), StringValuePtr(temp));
      }

      if (s != 0 && m->cleanup()) {
        delete s;
      }
    }
    break;

    case Marshall::ToSV:
    {
      QByteArray *s = (QByteArray*)m->item().s_voidp;
      if(s) {
        if (s->isNull()) {
          *(m->var()) = Qnil;
        } else {
          *(m->var()) = rstringFromQByteArray(s);
        }
        if(m->cleanup() || m->type().isStack() ) {
          delete s;
        }
      } else {
        *(m->var()) = Qnil;
      }
    }
    break;

    default:
      m->unsupported();
    break;
   }
}

void marshall_QDBusVariant(Marshall *m) {
    UNTESTED_HANDLER("marshall_QDBusVariant");
	switch(m->action()) {
	case Marshall::FromSV: 
	{
		VALUE v = *(m->var());
		if (v == Qnil) {
			m->item().s_voidp = 0;
			break;
		}

		smokeruby_object *o = value_obj_info(v);
		if (!o || !o->ptr) {
			if (m->type().isRef()) {
				m->unsupported();
			}
		    m->item().s_class = 0;
		    break;
		}
		m->item().s_class = o->ptr;
		break;
	}

	case Marshall::ToSV: 
	{
		if (m->item().s_voidp == 0) {
			*(m->var()) = Qnil;
		    break;
		}

		void *p = m->item().s_voidp;
		VALUE obj = getPointerObject(p);
		if(obj != Qnil) {
			*(m->var()) = obj;
		    break;
		}
		smokeruby_object * o = alloc_smokeruby_object(false, m->smoke(), m->smoke()->findClass("QVariant").index, p);
		
		obj = set_obj_info("Qt::DBusVariant", o);
		if (do_debug & qtdb_calls) {
			printf("allocating %s %p -> %p\n", "Qt::DBusVariant", o->ptr, (void*)obj);
		}

		if (m->type().isStack()) {
		    o->allocated = true;
			// Keep a mapping of the pointer so that it is only wrapped once
		    mapPointer(obj, o, o->classId, 0);
		}
		
		*(m->var()) = obj;
		break;
	}
	
	default:
		m->unsupported();
		break;
    }
}
*/
static void marshall_charP_array(Marshall* m) {
    // Not copied from ruby
    switch( m->action() ) {
        case Marshall::FromSV: {
            SV* arglistref = m->var();
            if ( !SvOK( arglistref ) && !SvROK( arglistref ) ) {
                m->item().s_voidp = 0;
                break;
            }

            AV* arglist = (AV*)SvRV( arglistref );

            int argc = av_len(arglist) + 1;
            char** argv = new char*[argc + 1];
            long i;
            for (i = 0; i < argc; ++i) {
                SV** item = av_fetch(arglist, i, 0);
                if( item ) {
                    STRLEN len = 0;
                    char* s = SvPV( *item, len );
                    argv[i] = new char[len + 1];
                    strcpy( argv[i], s );
                }
            }
            argv[i] = 0;
            m->item().s_voidp = argv;
            m->next();

            // No cleanup, we don't know what's pointing to us
        }
        break;

        default:
            m->unsupported();
        break;
    }
}

void marshall_QStringList(Marshall* m) {
    // Not copied from ruby
    switch(m->action()) {
        case Marshall::FromSV: {
            SV* listref = m->var();
            if( !SvROK(listref) && (SvTYPE(SvRV(listref)) != SVt_PVAV) ) {
                m->item().s_voidp = 0;
                break;
            }
            AV* list = (AV*)SvRV(listref);

            int count = av_len(list) + 1;
            QStringList *stringlist = new QStringList;

            for(long i = 0; i < count; i++) {
                SV** lookup = av_fetch( list, i, 0 );
                if( !lookup ) {
                    continue;
                }
                SV* item = *lookup;
                if(!item && ( SvPOK(item) ) ) {
                    stringlist->append(QString());
                    continue;
                }
                // TODO: handle different encodings
                stringlist->append(QString(SvPV_nolen(item)));
            }

            m->item().s_voidp = stringlist;
            m->next();

            if (stringlist != 0 && !m->type().isConst()) {
                av_clear(list);
                for(QStringList::Iterator it = stringlist->begin(); it != stringlist->end(); ++it)
                    // TODO: handle different encodings
                    av_push( list, newSVpv((*it).toLatin1().data(), 0) );
            }
                                
            if (m->cleanup()) {
                delete stringlist;
            }
            break;
        }
        case Marshall::ToSV: {
            QStringList *stringlist = static_cast<QStringList*>(m->item().s_voidp);
            if (!stringlist) {
                sv_setsv(m->var(), &PL_sv_undef);
                break;
            }

            AV* av = newAV();
            SV* sv = newRV_noinc( (SV*)av );
            for (QStringList::Iterator it = stringlist->begin(); it != stringlist->end(); ++it) {
                // TODO: handle different encodings
                av_push( av, newSVpv((*it).toLatin1().data(), 0) );
            }

            sv_setsv(m->var(), sv);

            if (m->cleanup()) {
                delete stringlist;
            }
        }
        break;
    default:
        m->unsupported();
        break;
    }
}

void marshall_QByteArrayList(Marshall *m) {
    UNTESTED_HANDLER("marshall_QByteArrayList");
    switch(m->action()) {
        case Marshall::FromSV: {
            SV *listref = m->var();
            if ( !SvOK( listref ) && !SvROK( listref ) ) {
                m->item().s_voidp = 0;
                break;
            }

            AV *list = (AV*)SvRV( listref );

            int count = av_len(list) + 1;
            QList<QByteArray> *stringlist = new QList<QByteArray>;

            for(long i = 0; i < count; ++i) {
                SV **item = av_fetch(list, i, 0);
                if( !item ) {
                    stringlist->append(QByteArray());
                    continue;
                }

                STRLEN len = 0;
                char *s = SvPV( *item, len );
                stringlist->append(QByteArray(s, len));
            }

            m->item().s_voidp = stringlist;
            m->next();

            if (!m->type().isConst()) {
                av_clear(list);
                for (int i = 0; i < stringlist->size(); i++) {
                    av_push(list, newSVpv((const char *) stringlist->at(i), 0));
                }
            }

            if(m->cleanup()) {
                delete stringlist;
            }
        }
        break;
        case Marshall::ToSV: {
            QList<QByteArray> *stringlist = static_cast<QList<QByteArray>*>(m->item().s_voidp);
            if(!stringlist) {
                sv_setsv(m->var(), &PL_sv_undef);
                break;
            }

            AV *av = newAV();
            for (int i = 0; i < stringlist->size(); i++) {
                SV *rv = newSVpv((const char *) stringlist->at(i), 0);
                av_push(av, rv);
            }

            sv_setsv( m->var(), newRV_noinc( (SV*)av ) );

            if (m->cleanup()) {
                delete stringlist;
            }
        }
        break;
        default:
            m->unsupported();
        break;
    }
}

void marshall_QListCharStar(Marshall *m) {
    UNTESTED_HANDLER("marshall_QListCharStar");
    switch(m->action()) {
        case Marshall::FromSV: {
            SV *avref = m->var();
            if ( !SvOK( avref ) && !SvROK( avref ) ) {
                m->item().s_voidp = 0;
                break;
            }

            AV *av = (AV*)SvRV( avref );

            int count = av_len(av) + 1;
            QList<const char*> *list = new QList<const char*>;
            long i;
            for(i = 0; i < count; ++i) {
                SV **item = av_fetch(av, i, 0);
                if ( !item ) {
                    list->append(0);
                    continue;
                }
                list->append(SvPV_nolen(*item));
            }

            m->item().s_voidp = list;
        }
        break;
        case Marshall::ToSV: {
            QList<const char*> *list = (QList<const char*>*)m->item().s_voidp;
            if (list == 0) {
                sv_setsv( m->var(), &PL_sv_undef );
                break;
            }

            AV *av = newAV();
            for ( QList<const char*>::iterator i = list->begin(); 
                  i != list->end(); 
                  ++i ) 
            {
                av_push(av, newSVpv((const char *)*i, 0));
            }

            sv_setsv( m->var(), newRV_noinc( (SV*)av ) );
            m->next();
        }
        break;
        default:
            m->unsupported();
        break;
    }
}

/*
void marshall_QListInt(Marshall *m) {
    UNTESTED_HANDLER("marshall_QListInt");
    switch(m->action()) {
      case Marshall::FromSV:
	{
	    VALUE list = *(m->var());
	    if (TYPE(list) != T_ARRAY) {
		m->item().s_voidp = 0;
		break;
	    }
	    int count = RARRAY_LEN(list);
	    QList<int> *valuelist = new QList<int>;
	    long i;
	    for(i = 0; i < count; i++) {
		VALUE item = rb_ary_entry(list, i);
		if(TYPE(item) != T_FIXNUM && TYPE(item) != T_BIGNUM) {
		    valuelist->append(0);
		    continue;
		}
		valuelist->append(NUM2INT(item));
	    }

	    m->item().s_voidp = valuelist;
	    m->next();

		if (!m->type().isConst()) {
			rb_ary_clear(list);
	
			for (	QList<int>::iterator i = valuelist->begin(); 
					i != valuelist->end(); 
					++i ) 
			{
				rb_ary_push(list, INT2NUM((int)*i));
			}
		}

		if (m->cleanup()) {
			delete valuelist;
	    }
	}
	break;
      case Marshall::ToSV:
	{
	    QList<int> *valuelist = (QList<int>*)m->item().s_voidp;
	    if(!valuelist) {
		*(m->var()) = Qnil;
		break;
	    }

	    VALUE av = rb_ary_new();

		for (	QList<int>::iterator i = valuelist->begin(); 
				i != valuelist->end(); 
				++i ) 
		{
		    rb_ary_push(av, INT2NUM((int)*i));
		}
		
	    *(m->var()) = av;
		m->next();

		if (m->cleanup()) {
			delete valuelist;
		}
	}
	break;
      default:
	m->unsupported();
	break;
    }
}

void marshall_QListUInt(Marshall *m) {
    UNTESTED_HANDLER("marshall_QListUInt");
    switch(m->action()) {
      case Marshall::FromSV:
	{
	    VALUE list = *(m->var());
	    if (TYPE(list) != T_ARRAY) {
		m->item().s_voidp = 0;
		break;
	    }
	    int count = RARRAY_LEN(list);
	    QList<uint> *valuelist = new QList<uint>;
	    long i;
	    for(i = 0; i < count; i++) {
		VALUE item = rb_ary_entry(list, i);
		if(TYPE(item) != T_FIXNUM && TYPE(item) != T_BIGNUM) {
		    valuelist->append(0);
		    continue;
		}
		valuelist->append(NUM2UINT(item));
	    }

	    m->item().s_voidp = valuelist;
	    m->next();

		if (!m->type().isConst()) {
			rb_ary_clear(list);
	
			for (	QList<uint>::iterator i = valuelist->begin(); 
					i != valuelist->end(); 
					++i ) 
			{
				rb_ary_push(list, UINT2NUM((int)*i));
			}
		}

		if (m->cleanup()) {
			delete valuelist;
	    }
	}
	break;
      case Marshall::ToSV:
	{
	    QList<uint> *valuelist = (QList<uint>*)m->item().s_voidp;
	    if(!valuelist) {
		*(m->var()) = Qnil;
		break;
	    }

	    VALUE av = rb_ary_new();

		for (	QList<uint>::iterator i = valuelist->begin(); 
				i != valuelist->end(); 
				++i ) 
		{
		    rb_ary_push(av, UINT2NUM((int)*i));
		}
		
	    *(m->var()) = av;
		m->next();

		if (m->cleanup()) {
			delete valuelist;
		}
	}
	break;
      default:
	m->unsupported();
	break;
    }
}

void marshall_QListqreal(Marshall *m) {
    UNTESTED_HANDLER("marshall_QListqreal");
    switch(m->action()) {
      case Marshall::FromSV:
	{
	    VALUE list = *(m->var());
	    if (TYPE(list) != T_ARRAY) {
		m->item().s_voidp = 0;
		break;
	    }
	    int count = RARRAY_LEN(list);
	    QList<qreal> *valuelist = new QList<qreal>;
	    long i;
	    for(i = 0; i < count; i++) {
		VALUE item = rb_ary_entry(list, i);
		if(TYPE(item) != T_FLOAT) {
		    valuelist->append(0.0);
		    continue;
		}
		valuelist->append(NUM2DBL(item));
	    }

	    m->item().s_voidp = valuelist;
	    m->next();

		if (!m->type().isConst()) {
			rb_ary_clear(list);
	
			for (	QList<qreal>::iterator i = valuelist->begin(); 
					i != valuelist->end(); 
					++i ) 
			{
				rb_ary_push(list, rb_float_new((qreal)*i));
			}
		}

		if (m->cleanup()) {
			delete valuelist;
		}
	}
	break;
      case Marshall::ToSV:
	{
	    QList<qreal> *valuelist = (QList<qreal>*)m->item().s_voidp;
	    if(!valuelist) {
		*(m->var()) = Qnil;
		break;
	    }

	    VALUE av = rb_ary_new();

		for (	QList<qreal>::iterator i = valuelist->begin(); 
				i != valuelist->end(); 
				++i ) 
		{
		    rb_ary_push(av, rb_float_new((qreal)*i));
		}
		
	    *(m->var()) = av;
		m->next();

		if (m->cleanup()) {
			delete valuelist;
		}
	}
	break;
      default:
	m->unsupported();
	break;
    }
}

void marshall_QVectorqreal(Marshall *m) {
    UNTESTED_HANDLER("marshall_QVectorqreal");
	switch(m->action()) {
	case Marshall::FromSV:
	{
		VALUE list = *(m->var());

		list = rb_check_array_type(*(m->var()));
		if (NIL_P(list)) {
			m->item().s_voidp = 0;
			break;
		}

		int count = RARRAY_LEN(list);
		QVector<qreal> *valuelist = new QVector<qreal>;
		long i;
		for (i = 0; i < count; i++) {
			valuelist->append(NUM2DBL(rb_ary_entry(list, i)));
		}

		m->item().s_voidp = valuelist;
		m->next();

		if (!m->type().isConst()) {
			rb_ary_clear(list);
	
			for (	QVector<qreal>::iterator i = valuelist->begin(); 
					i != valuelist->end(); 
					++i ) 
			{
				rb_ary_push(list, rb_float_new((qreal)*i));
			}
		}

		if (m->cleanup()) {
			delete valuelist;
		}
	}
	break;
	case Marshall::ToSV:
	{
	    QVector<qreal> *valuelist = (QVector<qreal>*)m->item().s_voidp;
	    if(!valuelist) {
		*(m->var()) = Qnil;
		break;
	    }

	    VALUE av = rb_ary_new();

		for (	QVector<qreal>::iterator i = valuelist->begin(); 
				i != valuelist->end(); 
				++i ) 
		{
		    rb_ary_push(av, rb_float_new((qreal)*i));
		}
		
	    *(m->var()) = av;
		m->next();

		if (m->cleanup()) {
			delete valuelist;
		}
	}
	break;
      default:
	m->unsupported();
	break;
    }
}

void marshall_QVectorint(Marshall *m) {
    UNTESTED_HANDLER("marshall_QVectorint");
	switch(m->action()) {
	case Marshall::FromSV:
	{
		VALUE list = *(m->var());

		list = rb_check_array_type(*(m->var()));
		if (NIL_P(list)) {
			m->item().s_voidp = 0;
			break;
		}

		int count = RARRAY_LEN(list);
		QVector<int> *valuelist = new QVector<int>;
		long i;
		for (i = 0; i < count; i++) {
			valuelist->append(NUM2INT(rb_ary_entry(list, i)));
		}

		m->item().s_voidp = valuelist;
		m->next();

		if (!m->type().isConst()) {
			rb_ary_clear(list);
	
			for (	QVector<int>::iterator i = valuelist->begin(); 
					i != valuelist->end(); 
					++i ) 
			{
				rb_ary_push(list, INT2NUM((int)*i));
			}
		}

		if (m->cleanup()) {
			delete valuelist;
		}
	}
	break;
	case Marshall::ToSV:
	{
	    QVector<int> *valuelist = (QVector<int>*)m->item().s_voidp;
	    if(!valuelist) {
		*(m->var()) = Qnil;
		break;
	    }

	    VALUE av = rb_ary_new();

		for (	QVector<int>::iterator i = valuelist->begin(); 
				i != valuelist->end(); 
				++i ) 
		{
		    rb_ary_push(av, INT2NUM((int)*i));
		}
		
	    *(m->var()) = av;
		m->next();

		if (m->cleanup()) {
			delete valuelist;
		}
	}
	break;
      default:
	m->unsupported();
	break;
    }
}

void marshall_voidP(Marshall *m) {
    UNTESTED_HANDLER("marshall_voidP");
    switch(m->action()) {
      case Marshall::FromSV:
	{
	    VALUE rv = *(m->var());
	    if (rv != Qnil)
		m->item().s_voidp = (void*)NUM2INT(*(m->var()));
	    else
		m->item().s_voidp = 0;
	}
	break;
      case Marshall::ToSV:
	{
	    *(m->var()) = Data_Wrap_Struct(rb_cObject, 0, 0, m->item().s_voidp);
	}
	break;
      default:
	m->unsupported();
	break;
    }
}

void marshall_QMapQStringQString(Marshall *m) {
    UNTESTED_HANDLER("marshall_QMapQStringQString");
    switch(m->action()) {
      case Marshall::FromSV:
	{
	    VALUE hash = *(m->var());
	    if (TYPE(hash) != T_HASH) {
		m->item().s_voidp = 0;
		break;
	    }
		
		QMap<QString,QString> * map = new QMap<QString,QString>;
		
		// Convert the ruby hash to an array of key/value arrays
		VALUE temp = rb_funcall(hash, rb_intern("to_a"), 0);

		for (long i = 0; i < RARRAY_LEN(temp); i++) {
			VALUE key = rb_ary_entry(rb_ary_entry(temp, i), 0);
			VALUE value = rb_ary_entry(rb_ary_entry(temp, i), 1);
			(*map)[QString(StringValuePtr(key))] = QString(StringValuePtr(value));
		}
	    
		m->item().s_voidp = map;
		m->next();
		
	    if(m->cleanup())
		delete map;
	}
	break;
      case Marshall::ToSV:
	{
	    QMap<QString,QString> *map = (QMap<QString,QString>*)m->item().s_voidp;
	    if(!map) {
		*(m->var()) = Qnil;
		break;
	    }
		
	    VALUE hv = rb_hash_new();
			
		QMap<QString,QString>::Iterator it;
		for (it = map->begin(); it != map->end(); ++it) {
			rb_hash_aset(hv, rstringFromQString((QString*)&(it.key())), rstringFromQString((QString*) &(it.value())));
        }
		
		*(m->var()) = hv;
		m->next();
		
	    if(m->cleanup())
		delete map;
	}
	break;
      default:
	m->unsupported();
	break;
    }
}

void marshall_QMapQStringQVariant(Marshall *m) {
    UNTESTED_HANDLER("marshall_QMapQStringQVariant");
	switch(m->action()) {
	case Marshall::FromSV:
	{
		VALUE hash = *(m->var());
		if (TYPE(hash) != T_HASH) {
			m->item().s_voidp = 0;
			break;
	    }
		
		QMap<QString,QVariant> * map = new QMap<QString,QVariant>;
		
		// Convert the ruby hash to an array of key/value arrays
		VALUE temp = rb_funcall(hash, rb_intern("to_a"), 0);

		for (long i = 0; i < RARRAY_LEN(temp); i++) {
			VALUE key = rb_ary_entry(rb_ary_entry(temp, i), 0);
			VALUE value = rb_ary_entry(rb_ary_entry(temp, i), 1);
			
			smokeruby_object *o = value_obj_info(value);
			if (!o || !o->ptr || o->classId != o->smoke->findClass("QVariant").index) {
				// If the value isn't a Qt::Variant, then try and construct
				// a Qt::Variant from it
				value = rb_funcall(qvariant_class, rb_intern("fromValue"), 1, value);
				if (value == Qnil) {
					continue;
				}
				o = value_obj_info(value);
			}
			
			(*map)[QString(StringValuePtr(key))] = (QVariant)*(QVariant*)o->ptr;
		}
	    
		m->item().s_voidp = map;
		m->next();
		
	    if(m->cleanup())
		delete map;
	}
	break;
      case Marshall::ToSV:
	{
	    QMap<QString,QVariant> *map = (QMap<QString,QVariant>*)m->item().s_voidp;
	    if(!map) {
		*(m->var()) = Qnil;
		break;
	    }
		
	    VALUE hv = rb_hash_new();
			
		QMap<QString,QVariant>::Iterator it;
		for (it = map->begin(); it != map->end(); ++it) {
			void *p = new QVariant(it.value());
			VALUE obj = getPointerObject(p);
				
			if (obj == Qnil) {
				smokeruby_object  * o = alloc_smokeruby_object(	true, 
																m->smoke(), 
																m->smoke()->idClass("QVariant").index, 
																p );
				obj = set_obj_info("Qt::Variant", o);
			}
			
			rb_hash_aset(hv, rstringFromQString((QString*)&(it.key())), obj);
        }
		
		*(m->var()) = hv;
		m->next();
		
	    if(m->cleanup())
		delete map;
	}
	break;
      default:
	m->unsupported();
	break;
    }
}

void marshall_QMapIntQVariant(Marshall *m) {
    UNTESTED_HANDLER("marshall_QMapIntQVariant");
	switch(m->action()) {
	case Marshall::FromSV:
	{
		VALUE hash = *(m->var());
		if (TYPE(hash) != T_HASH) {
			m->item().s_voidp = 0;
			break;
	    }
		
		QMap<int,QVariant> * map = new QMap<int,QVariant>;
		
		// Convert the ruby hash to an array of key/value arrays
		VALUE temp = rb_funcall(hash, rb_intern("to_a"), 0);

		for (long i = 0; i < RARRAY_LEN(temp); i++) {
			VALUE key = rb_ary_entry(rb_ary_entry(temp, i), 0);
			VALUE value = rb_ary_entry(rb_ary_entry(temp, i), 1);
			
			smokeruby_object *o = value_obj_info(value);
			if (!o || !o->ptr || o->classId != o->smoke->idClass("QVariant").index) {
				// If the value isn't a Qt::Variant, then try and construct
				// a Qt::Variant from it
				value = rb_funcall(qvariant_class, rb_intern("fromValue"), 1, value);
				if (value == Qnil) {
					continue;
				}
				o = value_obj_info(value);
			}
			
			(*map)[NUM2INT(key)] = (QVariant)*(QVariant*)o->ptr;
		}
	    
		m->item().s_voidp = map;
		m->next();
		
	    if(m->cleanup())
		delete map;
	}
	break;
      case Marshall::ToSV:
	{
	    QMap<int,QVariant> *map = (QMap<int,QVariant>*)m->item().s_voidp;
		if (!map) {
			*(m->var()) = Qnil;
			break;
	    }
		
	    VALUE hv = rb_hash_new();
			
		QMap<int,QVariant>::Iterator it;
		for (it = map->begin(); it != map->end(); ++it) {
			void *p = new QVariant(it.value());
			VALUE obj = getPointerObject(p);
				
			if (obj == Qnil) {
				smokeruby_object  * o = alloc_smokeruby_object(	true, 
																m->smoke(), 
																m->smoke()->idClass("QVariant").index, 
																p );
				obj = set_obj_info("Qt::Variant", o);
			}
			
			rb_hash_aset(hv, INT2NUM(it.key()), obj);
        }
		
		*(m->var()) = hv;
		m->next();
		
	    if(m->cleanup())
		delete map;
	}
	break;
      default:
	m->unsupported();
	break;
    }
}

void marshall_QMapintQVariant(Marshall *m) {
    UNTESTED_HANDLER("marshall_QMapintQVariant");
    switch(m->action()) {
      case Marshall::FromSV:
	{
	    VALUE hash = *(m->var());
	    if (TYPE(hash) != T_HASH) {
		m->item().s_voidp = 0;
		break;
	    }
		
		QMap<int,QVariant> * map = new QMap<int,QVariant>;
		
		// Convert the ruby hash to an array of key/value arrays
		VALUE temp = rb_funcall(hash, rb_intern("to_a"), 0);

		for (long i = 0; i < RARRAY_LEN(temp); i++) {
			VALUE key = rb_ary_entry(rb_ary_entry(temp, i), 0);
			VALUE value = rb_ary_entry(rb_ary_entry(temp, i), 1);
			
			smokeruby_object *o = value_obj_info(value);
			if( !o || !o->ptr)
                   continue;
			void * ptr = o->ptr;
			ptr = o->smoke->cast(ptr, o->classId, o->smoke->idClass("QVariant").index);
			
			(*map)[NUM2INT(key)] = (QVariant)*(QVariant*)ptr;
		}
	    
		m->item().s_voidp = map;
		m->next();
		
	    if(m->cleanup())
		delete map;
	}
	break;
      case Marshall::ToSV:
	{
	    QMap<int,QVariant> *map = (QMap<int,QVariant>*)m->item().s_voidp;
	    if(!map) {
		*(m->var()) = Qnil;
		break;
	    }
		
	    VALUE hv = rb_hash_new();
			
		QMap<int,QVariant>::Iterator it;
		for (it = map->begin(); it != map->end(); ++it) {
			void *p = new QVariant(it.value());
			VALUE obj = getPointerObject(p);
				
			if (obj == Qnil) {
				smokeruby_object  * o = alloc_smokeruby_object(	true, 
																m->smoke(), 
																m->smoke()->idClass("QVariant").index, 
																p );
				obj = set_obj_info("Qt::Variant", o);
			}
			
			rb_hash_aset(hv, INT2NUM((int)(it.key())), obj);
        }
		
		*(m->var()) = hv;
		m->next();
		
	    if(m->cleanup())
		delete map;
	}
	break;
      default:
	m->unsupported();
	break;
    }
}

void marshall_voidP_array(Marshall *m) {
    UNTESTED_HANDLER("marshall_voidP_array");
    switch(m->action()) {
	case Marshall::FromSV:
	{
	    VALUE rv = *(m->var());
		if (rv != Qnil) {
			Data_Get_Struct(rv, void*, m->item().s_voidp);
		} else {
			m->item().s_voidp = 0;
		}
	}
	break;
	case Marshall::ToSV:
	{
		VALUE rv = Data_Wrap_Struct(rb_cObject, 0, 0, m->item().s_voidp);
		*(m->var()) = rv;
	}
	break;
		default:
		m->unsupported();
	break;
    }
}

void marshall_QRgb_array(Marshall *m) {
    UNTESTED_HANDLER("marshall_QRgb_array");
    switch(m->action()) {
      case Marshall::FromSV:
	{
	    VALUE list = *(m->var());
	    if (TYPE(list) != T_ARRAY) {
		m->item().s_voidp = 0;
		break;
	    }
	    int count = RARRAY_LEN(list);
	    QRgb *rgb = new QRgb[count + 2];
	    long i;
	    for(i = 0; i < count; i++) {
		VALUE item = rb_ary_entry(list, i);
		if(TYPE(item) != T_FIXNUM && TYPE(item) != T_BIGNUM) {
		    rgb[i] = 0;
		    continue;
		}

		rgb[i] = NUM2UINT(item);
	    }
	    m->item().s_voidp = rgb;
	    m->next();
	}
	break;
      case Marshall::ToSV:
	// Implement this with a tied array or something
      default:
	m->unsupported();
	break;
    }
}

void marshall_QPairQStringQStringList(Marshall *m) {
    UNTESTED_HANDLER("marshall_QPairQStringQStringList");
	switch(m->action()) {
	case Marshall::FromSV: 
	{
		VALUE list = *(m->var());
		if (TYPE(list) != T_ARRAY) {
			m->item().s_voidp = 0;
			break;
	    }

		QList<QPair<QString,QString> > * pairlist = new QList<QPair<QString,QString> >();
		int count = RARRAY_LEN(list);

		for (long i = 0; i < count; i++) {
			VALUE item = rb_ary_entry(list, i);
			if (TYPE(item) != T_ARRAY || RARRAY_LEN(item) != 2) {
				continue;
			}
			VALUE s1 = rb_ary_entry(item, 0);
			VALUE s2 = rb_ary_entry(item, 1);
			QPair<QString,QString> * qpair = new QPair<QString,QString>(*(qstringFromRString(s1)),*(qstringFromRString(s2)));
			pairlist->append(*qpair);
		}

		m->item().s_voidp = pairlist;
		m->next();
			
		if (m->cleanup()) {
			delete pairlist;
		}
	   
		break;
	}

	case Marshall::ToSV: 
	{
		QList<QPair<QString,QString> > *pairlist = static_cast<QList<QPair<QString,QString> > * >(m->item().s_voidp);
		if (pairlist == 0) {
			*(m->var()) = Qnil;
			break;
		}

		VALUE av = rb_ary_new();
		for (QList<QPair<QString,QString> >::Iterator it = pairlist->begin(); it != pairlist->end(); ++it) {
			QPair<QString,QString> * pair = &(*it);
			VALUE rv1 = rstringFromQString(&(pair->first));
			VALUE rv2 = rstringFromQString(&(pair->second));
			VALUE pv = rb_ary_new();
			rb_ary_push(pv, rv1);
			rb_ary_push(pv, rv2);
			rb_ary_push(av, pv);
		}

		*(m->var()) = av;

		if (m->cleanup()) {
			delete pairlist;
		}

	}
	break;
	default:
		m->unsupported();
		break;
    }
}

void marshall_QPairqrealQColor(Marshall *m) {
    UNTESTED_HANDLER("marshall_QPairqrealQColor");
	switch(m->action()) {
	case Marshall::FromSV:
	{
		VALUE list = *(m->var());
		if (TYPE(list) != T_ARRAY || RARRAY_LEN(list) != 2) {
			m->item().s_voidp = 0;
			break;
	    }

		qreal real;
		VALUE item1 = rb_ary_entry(list, 0);
		if (TYPE(item1) != T_FLOAT) {
		    real = 0;
		} else {
			real = NUM2DBL(item1);
		}
		
		VALUE item2 = rb_ary_entry(list, 1);

		smokeruby_object *o = value_obj_info(item2);
		if (o == 0 || o->ptr == 0) {
			m->item().s_voidp = 0;
			break;
		}
		
		QPair<qreal,QColor> * qpair = new QPair<qreal,QColor>(real, *((QColor *) o->ptr));
		m->item().s_voidp = qpair;
		m->next();

		if (m->cleanup()) {
			delete qpair;
		}
	}
	break;
	case Marshall::ToSV:
	{
		QPair<qreal,QColor> * qpair = static_cast<QPair<qreal,QColor> * >(m->item().s_voidp); 
		if (qpair == 0) {
			*(m->var()) = Qnil;
			break;
		}

		VALUE rv1 = rb_float_new(qpair->first);

		void *p = (void *) &(qpair->second);
		VALUE rv2 = getPointerObject(p);
		if (rv2 == Qnil) {
			smokeruby_object  * o = alloc_smokeruby_object(	false, 
															m->smoke(), 
															m->smoke()->idClass("QColor").index, 
															p );
			rv2 = set_obj_info("Qt::Color", o);
		}

		VALUE av = rb_ary_new();
		rb_ary_push(av, rv1);
		rb_ary_push(av, rv2);
		*(m->var()) = av;

		if (m->cleanup()) {
//			delete qpair;
		}
	}
		break;
	default:
		m->unsupported();
		break;
    }
}

void marshall_QPairintint(Marshall *m) {
    UNTESTED_HANDLER("marshall_QPairintint");
	switch(m->action()) {
	case Marshall::FromSV:
	{
		VALUE list = *(m->var());
		if (TYPE(list) != T_ARRAY || RARRAY_LEN(list) != 2) {
			m->item().s_voidp = 0;
			break;
	    }
		int int0;
		int int1;
		VALUE item = rb_ary_entry(list, 0);
		if (TYPE(item) != T_FIXNUM && TYPE(item) != T_BIGNUM) {
		    int0 = 0;
		} else {
			int0 = NUM2INT(item);
		}
		
		item = rb_ary_entry(list, 1);

		if (TYPE(item) != T_FIXNUM && TYPE(item) != T_BIGNUM) {
		    int1 = 0;
		} else {
			int1 = NUM2INT(item);
		}
		
		QPair<int,int> * qpair = new QPair<int,int>(int0,int1);
		m->item().s_voidp = qpair;
		m->next();

		if (m->cleanup()) {
			delete qpair;
		}
	}
	break;
      case Marshall::ToSV:
      default:
	m->unsupported();
	break;
    }
}
*/
void marshall_voidP_array(Marshall *m) {
    // This is a hack that should be removed.
    switch(m->action()) {
        case Marshall::FromSV:
        {
            m->unsupported();
        }
        break;
        case Marshall::ToSV:
        {
            // This is ghetto.
            void* cxxptr = m->item().s_voidp;

            SV *var = allocSmokePerlSV( cxxptr, m->type() );
            sv_bless( var, gv_stashpv( "voidparray", TRUE ) );

            SvSetMagicSV(m->var(), var);
        }
        break;
        default:
            m->unsupported();
        break;
    }
}

Q_DECL_EXPORT TypeHandler Qt_handlers[] = {
    { "bool*", marshall_it<bool *> },
    { "bool&", marshall_it<bool *> },
    { "char**", marshall_charP_array },
    { "char*",marshall_it<char *> },
    //{ "DOM::DOMTimeStamp", marshall_it<long long> },
    { "double*", marshall_doubleR },
    { "double&", marshall_doubleR },
    { "int*", marshall_it<int *> },
    { "int&", marshall_it<int *> },
    //{ "KIO::filesize_t", marshall_it<long long> },
    //{ "long long int", marshall_it<long long> },
    //{ "long long int&", marshall_it<long long> },
    //{ "QDBusVariant", marshall_QDBusVariant },
    //{ "QDBusVariant&", marshall_QDBusVariant },
    //{ "QList<QFileInfo>", marshall_QFileInfoList },
    //{ "QFileInfoList", marshall_QFileInfoList },
    //{ "QGradiantStops", marshall_QPairqrealQColor },
    //{ "QGradiantStops&", marshall_QPairqrealQColor },
    //{ "unsigned int&", marshall_it<unsigned int *> },
    //{ "quint32&", marshall_it<unsigned int *> },
    //{ "uint&", marshall_it<unsigned int *> },
    { "qint32&", marshall_it<int *> },
    //{ "qint64", marshall_it<long long> },
    //{ "qint64&", marshall_it<long long> },
    //{ "QList<const char*>", marshall_QListCharStar },
    //{ "QList<int>", marshall_QListInt },
    //{ "QList<int>&", marshall_QListInt },
    //{ "QList<uint>", marshall_QListUInt },
    //{ "QList<uint>&", marshall_QListUInt },
    //{ "QList<QAbstractButton*>", marshall_QAbstractButtonList },
    //{ "QList<QActionGroup*>", marshall_QActionGroupList },
    //{ "QList<QAction*>", marshall_QActionList },
    //{ "QList<QAction*>&", marshall_QActionList },
    //{ "QList<QByteArray>", marshall_QByteArrayList },
    //{ "QList<QByteArray>*", marshall_QByteArrayList },
    //{ "QList<QByteArray>&", marshall_QByteArrayList },
    ////{ "QList<QHostAddress>", marshall_QHostAddressList },
    //{ "QList<QHostAddress>&", marshall_QHostAddressList },
    //{ "QList<QImageTextKeyLang>", marshall_QImageTextKeyLangList },
    //{ "QList<QKeySequence>", marshall_QKeySequenceList },
    //{ "QList<QKeySequence>&", marshall_QKeySequenceList },
    //{ "QList<QListWidgetItem*>", marshall_QListWidgetItemList },
    //{ "QList<QListWidgetItem*>&", marshall_QListWidgetItemList },
    //{ "QList<QModelIndex>", marshall_QModelIndexList },
    //{ "QList<QModelIndex>&", marshall_QModelIndexList },
    //{ "QList<QNetworkAddressEntry>", marshall_QNetworkAddressEntryList },
    //{ "QList<QNetworkInterface>", marshall_QNetworkInterfaceList },
    //{ "QList<QPair<QString,QString> >", marshall_QPairQStringQStringList },
    //{ "QList<QPair<QString,QString> >&", marshall_QPairQStringQStringList },
    //{ "QList<QPixmap>", marshall_QPixmapList },
    //{ "QList<QPolygonF>", marshall_QPolygonFList },
    //{ "QList<QRectF>", marshall_QRectFList },
    //{ "QList<QRectF>&", marshall_QRectFList },
    //{ "QList<qreal>", marshall_QListqreal },
    //{ "QList<double>", marshall_QListqreal },
    //{ "QwtValueList", marshall_QListqreal },
    //{ "QwtValueList&", marshall_QListqreal },
    //{ "QList<double>&", marshall_QListqreal },
    //{ "QList<QObject*>", marshall_QObjectList },
    //{ "QList<QObject*>&", marshall_QObjectList },
    //{ "QList<QTableWidgetItem*>", marshall_QTableWidgetItemList },
    //{ "QList<QTableWidgetItem*>&", marshall_QTableWidgetItemList },
    //{ "QList<QTableWidgetSelectionRange>", marshall_QTableWidgetSelectionRangeList },
    //{ "QList<QTextBlock>", marshall_QTextBlockList },
    //{ "QList<QTextEdit::ExtraSelection>", marshall_QTextEditExtraSelectionsList },
    //{ "QList<QTextEdit::ExtraSelection>&", marshall_QTextEditExtraSelectionsList },
    ////{ "QList<QTextFrame*>", marshall_QTextFrameList },
    //{ "QList<QTextLayout::FormatRange>", marshall_QTextLayoutFormatRangeList },
    //{ "QList<QTextLayout::FormatRange>&", marshall_QTextLayoutFormatRangeList },
    //{ "QList<QTreeWidgetItem*>", marshall_QTreeWidgetItemList },
    //{ "QList<QTreeWidgetItem*>&", marshall_QTreeWidgetItemList },
    //{ "QList<QUndoStack*>", marshall_QUndoStackList },
    //{ "QList<QUndoStack*>&", marshall_QUndoStackList },
    //{ "QList<QUrl>", marshall_QUrlList },
    //{ "QList<QUrl>&", marshall_QUrlList },
    //{ "QList<QVariant>", marshall_QVariantList },
    //{ "QList<QVariant>&", marshall_QVariantList },
    //{ "QList<QWidget*>", marshall_QWidgetPtrList },
    //{ "QList<QWidget*>&", marshall_QWidgetPtrList },
    //{ "qlonglong", marshall_it<long long> },
    //{ "qlonglong&", marshall_it<long long> },
    //{ "QMap<int,QVariant>", marshall_QMapintQVariant },
    //{ "QMap<int,QVariant>", marshall_QMapIntQVariant },
    //{ "QMap<int,QVariant>&", marshall_QMapIntQVariant },
    //{ "QMap<QString,QString>", marshall_QMapQStringQString },
    //{ "QMap<QString,QString>&", marshall_QMapQStringQString },
    //{ "QMap<QString,QVariant>", marshall_QMapQStringQVariant },
    //{ "QMap<QString,QVariant>&", marshall_QMapQStringQVariant },
    //{ "QVariantMap", marshall_QMapQStringQVariant },
    //{ "QVariantMap&", marshall_QMapQStringQVariant },
    //{ "QModelIndexList", marshall_QModelIndexList },
    //{ "QModelIndexList&", marshall_QModelIndexList },
    //{ "QObjectList", marshall_QObjectList },
    //{ "QObjectList&", marshall_QObjectList },
    //{ "QPair<int,int>&", marshall_QPairintint },
    //{ "Q_PID", marshall_it<Q_PID> },
    { "qreal*", marshall_doubleR },
    { "qreal&", marshall_doubleR },
    //{ "QRgb*", marshall_QRgb_array },
    { "QStringList", marshall_QStringList },
    { "QStringList*", marshall_QStringList },
    { "QStringList&", marshall_QStringList },
    { "QString", marshall_QString },
    { "QString*", marshall_QString },
    { "QString&", marshall_QString },
    //{ "QByteArray", marshall_QByteArray },
    //{ "QByteArray*", marshall_QByteArray },
    //{ "QByteArray&", marshall_QByteArray },
    //{ "quint64", marshall_it<unsigned long long> },
    //{ "quint64&", marshall_it<unsigned long long> },
    //{ "qulonglong", marshall_it<unsigned long long> },
    //{ "qulonglong&", marshall_it<unsigned long long> },
    //{ "QVariantList&", marshall_QVariantList },
    //{ "QVector<int>", marshall_QVectorint },
    //{ "QVector<int>&", marshall_QVectorint },
    //{ "QVector<QColor>", marshall_QColorVector },
    //{ "QVector<QColor>&", marshall_QColorVector },
    //{ "QVector<QLineF>", marshall_QLineFVector },
    //{ "QVector<QLineF>&", marshall_QLineFVector },
    //{ "QVector<QLine>", marshall_QLineVector },
    //{ "QVector<QLine>&", marshall_QLineVector },
    //{ "QVector<QPointF>", marshall_QPointFVector },
    //{ "QVector<QPointF>&", marshall_QPointFVector },
    //{ "QVector<QPoint>", marshall_QPointVector },
    //{ "QVector<QPoint>&", marshall_QPointVector },
    //{ "QVector<qreal>", marshall_QVectorqreal },
    //{ "QVector<qreal>&", marshall_QVectorqreal },
    //{ "QVector<QRectF>", marshall_QRectFVector },
    //{ "QVector<QRectF>&", marshall_QRectFVector },
    //{ "QVector<QRect>", marshall_QRectVector },
    //{ "QVector<QRect>&", marshall_QRectVector },
    //{ "QVector<QRgb>", marshall_QRgbVector },
    //{ "QVector<QRgb>&", marshall_QRgbVector },
    //{ "QVector<QTextFormat>", marshall_QTextFormatVector },
    //{ "QVector<QTextFormat>&", marshall_QTextFormatVector },
    //{ "QVector<QTextLength>", marshall_QTextLengthVector },
    //{ "QVector<QTextLength>&", marshall_QTextLengthVector },
    //{ "QVector<QVariant>", marshall_QVariantVector },
    //{ "QVector<QVariant>&", marshall_QVariantVector },
    //{ "QWidgetList", marshall_QWidgetList },
    //{ "QWidgetList&", marshall_QWidgetList },
    //{ "QwtArray<double>", marshall_QVectorqreal },
    //{ "QwtArray<double>&", marshall_QVectorqreal },
    //{ "QwtArray<int>", marshall_QVectorint },
    //{ "QwtArray<int>&", marshall_QVectorint },
    { "signed int&", marshall_it<int *> },
    //{ "uchar*", marshall_ucharP },
    //{ "unsigned long long int", marshall_it<long long> },
    //{ "unsigned long long int&", marshall_it<long long> },
    { "void", marshall_void },
    { "void**", marshall_voidP_array },
    //{ "WId", marshall_it<WId> },
#if QT_VERSION >= 0x40200
    //{ "QList<QGraphicsItem*>", marshall_QGraphicsItemList },
    //{ "QList<QGraphicsItem*>&", marshall_QGraphicsItemList },
    //{ "QList<QStandardItem*>", marshall_QStandardItemList },
    //{ "QList<QStandardItem*>&", marshall_QStandardItemList },
    //{ "QList<QUndoStack*>", marshall_QUndoStackList },
    //{ "QList<QUndoStack*>&", marshall_QUndoStackList },
#endif
#if QT_VERSION >= 0x40300
    //{ "QList<QMdiSubWindow*>", marshall_QMdiSubWindowList },
    //{ "QList<QSslCertificate>", marshall_QSslCertificateList },
    //{ "QList<QSslCertificate>&", marshall_QSslCertificateList },
    //{ "QList<QSslCipher>", marshall_QSslCipherList },
    //{ "QList<QSslCipher>&", marshall_QSslCipherList },
    //{ "QList<QSslError>", marshall_QSslErrorList },
    //{ "QList<QSslError>&", marshall_QSslErrorList },
    //{ "QXmlStreamEntityDeclarations", marshall_QXmlStreamEntityDeclarations },
    //{ "QXmlStreamNamespaceDeclarations", marshall_QXmlStreamNamespaceDeclarations },
    //{ "QXmlStreamNotationDeclarations", marshall_QXmlStreamNotationDeclarations },
#endif
#if QT_VERSION >= 0x040400
    //{ "QList<QNetworkCookie>", marshall_QNetworkCookieList },
    //{ "QList<QNetworkCookie>&", marshall_QNetworkCookieList },
    //{ "QList<QPrinterInfo>", marshall_QPrinterInfoList },
#endif
    { 0, 0 }
};

void install_handlers(TypeHandler *handler) {
    if(!type_handlers) type_handlers = newHV();
    while(handler->name) {
        hv_store(type_handlers, handler->name, strlen(handler->name), newSViv((IV)handler), 0);
        handler++;
    }
}

Marshall::HandlerFn getMarshallFn(const SmokeType &type) {
    if(type.elem()) // If it's not t_voidp
        return marshall_basetype;
    if(!type.name())
        return marshall_void;

    U32 len = strlen(type.name());
    //fprintf( stderr, "Request to marshall %s\n", type.name() );
    SV **svp = hv_fetch(type_handlers, type.name(), len, 0);

    //                           len > strlen("const ")
    if(!svp && type.isConst() && len > 6) {
        // Look for a type name that doesn't include const.
        svp = hv_fetch(type_handlers, type.name() + 6, len - 6, 0);
    }

    if(svp) {
        TypeHandler *h = (TypeHandler*)SvIV(*svp);
        return h->fn;
    }

    return marshall_unknown;
}
