#include "handlers.h"
#include "Qt.h"
#include "QtCore/QHash"
#include "QtCore/QString"
#include "QtCore/QStringList"
#include "marshall_basetypes.h"
extern HV* pointer_map;
#include "marshall_macros.h"

#if QT_VERSION >= 0X40300
#include "QtGui/QMdiSubWindow"
#endif

// The only reason magic is there is to deallocate memory on qt objects when
// their associated perl scalar goes out of scope
// struct mgvtbl vtbl_smoke = { 0, 0, 0, 0, smokeperl_free };

void marshall_QString(Marshall *m){
    switch(m->action()) {
      case Marshall::FromSV:
        {
            SV* sv = m->var();
            QString* mystr = new QString( SvPV_nolen(sv) );
            m->item().s_voidp = (void*)mystr;
        }
        break;
      case Marshall::ToSV:
        {
            QString* cxxptr = (QString*)m->item().s_voidp;
            sv_setpv( m->var(), cxxptr->toAscii() );
        }
        break;
      default:
        m->unsupported();
        break;
    }
}

static void marshall_charP(Marshall *m) {
    switch(m->action()) {
      case Marshall::FromSV:
        {
            SV *sv = m->var();
            if(!SvOK(sv)) {
                m->item().s_voidp = 0;
                break;
            }
            if(m->cleanup())
                m->item().s_voidp = SvPV_nolen(sv);
            else {
                STRLEN len;
                char *svstr = SvPV(sv, len);
                char *str = new char [len + 1];
                strncpy(str, svstr, len);
                str[len] = 0;
                m->item().s_voidp = str;
            }
        }
        break;
      case Marshall::ToSV:
        {
            char *p = (char*)m->item().s_voidp;
            if(p)
                sv_setpv_mg(m->var(), p);
            else
                sv_setsv_mg(m->var(), &PL_sv_undef);
            if(m->cleanup())
                delete[] p;
        }
        break;
      default:
        m->unsupported();
        break;
    }
}

void marshall_QStringList(Marshall *m) {
    switch(m->action()) {
        case Marshall::FromSV: {
            SV* listref = m->var();
            if( !SvROK(listref) && (SvTYPE(SvRV(listref)) != SVt_PVAV) ) {
                fprintf( stderr, "Not an array\n" );
                m->item().s_voidp = 0;
                break;
            }
            AV* list = (AV*)SvRV(listref);

            int count = av_len(list) + 1;
            fprintf(stderr, "Got %d elements\n", count);
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
            /*
            m->next();

            if (stringlist != 0 && !m->type().isConst()) {
                rb_ary_clear(list);
                for(QStringList::Iterator it = stringlist->begin(); it != stringlist->end(); ++it)
                rb_ary_push(list, rstringFromQString(&(*it)));
            }
            
            if (m->cleanup()) {
                delete stringlist;
            }
            */ 
            break;
        }
        case Marshall::ToSV: {
            m->unsupported();
            /*
            QStringList *stringlist = static_cast<QStringList *>(m->item().s_voidp);
            if (!stringlist) {
                *(m->var()) = Qnil;
                break;
            }

            VALUE av = rb_ary_new();
            for (QStringList::Iterator it = stringlist->begin(); it != stringlist->end(); ++it) {
                VALUE rv = rstringFromQString(&(*it));
                rb_ary_push(av, rv);
            }

            *(m->var()) = av;

            if (m->cleanup()) {
                delete stringlist;
            }
            */
        }
        break;
    default:
        m->unsupported();
        break;
    }
}

void marshall_voidP_array(Marshall *m) {
    switch(m->action()) {
        case Marshall::FromSV:
        {
            m->unsupported();
        }
        break;
        case Marshall::ToSV:
        {
            // This is ghetto.
            //fprintf( stderr, "ToSV\n" );

            void* cxxptr = m->item().s_voidp;

            HV *hv = newHV();
            SV *var = newRV_noinc((SV*)hv);
            sv_bless( var, gv_stashpv( "voidparray", TRUE ) );

            smokeperl_object o;
            o.smoke = m->smoke();
            o.classId = m->type().classId();
            o.ptr = cxxptr;
            o.allocated = true;

            sv_magic((SV*)hv, 0, '~', (char*)&o, sizeof(o));
            SvSetMagicSV(m->var(), var);

            SvREFCNT_dec(var);
        }
        break;
        default:
            m->unsupported();
        break;
    }
}

template <class T>
static void marshall_it(Marshall *m) {
    switch(m->action()) {
        case Marshall::FromSV:
            marshall_from_perl<T>(m);
        break;

        case Marshall::ToSV:
            marshall_to_perl<T>(m);
        break;

        default:
            m->unsupported();
        break;
    }
}

void marshall_basetype(Marshall *m) {
    switch(m->type().elem()) {

        case Smoke::t_bool:
            marshall_it<bool>(m);
        break;

		case Smoke::t_int:
			marshall_it<int>(m);
		break;
		
		case Smoke::t_uint:
			marshall_it<unsigned int>(m);
		break;

		case Smoke::t_double:
			marshall_it<double>(m);
		break;

      case Smoke::t_enum:
        switch(m->action()) {
          case Marshall::FromSV:
            m->item().s_enum = (long)SvIV(SvRV(m->var()));
            break;
          case Marshall::ToSV:{
            SV* rv = newRV(newSViv((IV)m->item().s_enum));
            sv_bless( rv, gv_stashpv(m->type().name(), TRUE) );
            sv_setsv(m->var(), rv);
            break;
          }
          default:
            m->unsupported();
            break;
        }
        break;
      case Smoke::t_class:
        switch(m->action()) {
          case Marshall::FromSV:
            {
                // Get the c++ pointer out of the sv, and put it on the stack.
                smokeperl_object* o = sv_obj_info( m->var() );
                m->item().s_voidp = o->ptr;
            }
            break;
          case Marshall::ToSV:
            {
                if(!m->item().s_voidp) {
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

                // The hash
                HV *hv = newHV();
                // The hash reference to return
                var = newRV_noinc((SV*)hv);

                // What class does the datatype of the return value belong to?
                Smoke::Index classid = m->type().classId();
                // What package should I bless as?
                char *retpackage = perlqt_modules[m->smoke()].binding->className(classid);
                // Phew.  Bless the sv.
                sv_bless( var, gv_stashpv(retpackage, TRUE) );

                // Now we need to associate the pointer to the returned value with the sv
                // We need to throw the pointer into a struct, because we know the
                // size of the struct, but we don't know the size of a void*
                smokeperl_object o;
                o.smoke = m->smoke();
                o.classId = m->type().classId();
                o.ptr = cxxptr;
                o.allocated = false;
                 
                // For this, we need a magic wand.  This is what actually
                // stores 'o' into our hash.
                sv_magic((SV*)hv, 0, '~', (char*)&o, sizeof(o));

                // Copy our local var into the marshaller's var, and make
                // sure to copy our magic with it
                SvSetMagicSV(m->var(), var);

                // Store this into the ptr map for reference from virtual
                // function calls.
                mapPointer(var, &o, pointer_map, o.classId, 0);

                // We're done with our local var
                SvREFCNT_dec(var);
            }
            break;
          default:
            m->unsupported();
            break;
        }
        break;
      default:
        m->unsupported();
        break;
    }
}

void marshall_void(Marshall *) {}
void marshall_unknown(Marshall *m) { m->unsupported(); }

HV *type_handlers = 0;

void install_handlers(TypeHandler *handler) {
    if(!type_handlers) type_handlers = newHV();
    while(handler->name) {
        hv_store(type_handlers, handler->name, strlen(handler->name), newSViv((IV)handler), 0);
        handler++;
    }
}

#if QT_VERSION >= 0x40300
DEF_LIST_MARSHALLER( QMdiSubWindowList, QList<QMdiSubWindow*>, QMdiSubWindow )
#endif

TypeHandler Qt_handlers[] = {
    { "QString", marshall_QString },
    { "QString&", marshall_QString },
    { "QString*", marshall_QString },
    { "QStringList", marshall_QStringList },
    { "QStringList*", marshall_QStringList },
    { "QStringList&", marshall_QStringList },
    { "const QString", marshall_QString },
    { "const QString&", marshall_QString },
    { "const QString*", marshall_QString },
    { "char*", marshall_charP },
    { "const char*", marshall_charP },
    { "void", marshall_void },
    { "void**", marshall_voidP_array },
#if QT_VERSION >= 0x40300
    { "QList<QMdiSubWindow*>", marshall_QMdiSubWindowList },
#endif
    { 0, 0 }
};

Marshall::HandlerFn getMarshallFn(const SmokeType &type) {
    if(type.elem()) // If it's not t_voidp
        return marshall_basetype;
    if(!type.name())
        return marshall_void;

    U32 len = strlen(type.name());
    SV **svp = hv_fetch(type_handlers, type.name(), len, 0);

    if(!svp && type.isConst() && len > strlen("const "))
        svp = hv_fetch(type_handlers, type.name() + 6, len - 6, 0);
    if(svp) {
        TypeHandler *h = (TypeHandler*)SvIV(*svp);
        return h->fn;
    }
    return marshall_unknown;
}
