#include "QtCore/QHash"
#include "QtCore/QString"
#include "QtCore/QStringList"
#if QT_VERSION >= 0X40300
#include "QtGui/QMdiSubWindow"
#endif

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

void marshall_basetype(Marshall* m) {
    switch( m->type().elem() ) {

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

static void marshall_charP_array(Marshall* m) {
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

void marshall_QString(Marshall* m) {
    switch(m->action()) {
      case Marshall::FromSV: {
            SV* sv = m->var();
            QString* mystr = 0;
            if( SvOK(sv) ) {
                mystr = new QString( SvPV_nolen(sv) );
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
                    sv_setpv( m->var(), cxxptr->toAscii() );
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

void marshall_QStringList(Marshall* m) {
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

void marshall_unknown(Marshall *m) { m->unsupported(); }

void marshall_void(Marshall *) {}

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

void install_handlers(TypeHandler *handler) {
    if(!type_handlers) type_handlers = newHV();
    while(handler->name) {
        hv_store(type_handlers, handler->name, strlen(handler->name), newSViv((IV)handler), 0);
        handler++;
    }
}

TypeHandler Qt_handlers[] = {
    { "char**", marshall_charP_array },
    { "char*", marshall_it<char*> },
    { "int&", marshall_it<int*> },
    { "QString", marshall_QString },
    { "QString&", marshall_QString },
    { "QString*", marshall_QString },
    { "const QString", marshall_QString },
    { "const QString&", marshall_QString },
    { "const QString*", marshall_QString },
    { "QStringList", marshall_QStringList },
    { "QStringList*", marshall_QStringList },
    { "QStringList&", marshall_QStringList },
    { "void", marshall_void },
    { "void**", marshall_voidP_array },
    { 0, 0 }
};

Marshall::HandlerFn getMarshallFn(const SmokeType &type) {
    if(type.elem()) // If it's not t_voidp
        return marshall_basetype;
    if(!type.name())
        return marshall_void;

    U32 len = strlen(type.name());
    SV **svp = hv_fetch(type_handlers, type.name(), len, 0);

    //                           len > strlen("const ")
    if(!svp && type.isConst() && len > 6)
        svp = hv_fetch(type_handlers, type.name() + 6, len - 6, 0);
    if(svp) {
        TypeHandler *h = (TypeHandler*)SvIV(*svp);
        return h->fn;
    }
    return marshall_unknown;
}
