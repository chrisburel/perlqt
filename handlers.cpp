#include "handlers.h"
#include "Qt.h"
#include "QtCore/qstring.h"
#include "QtCore/QHash"
#include "marshall_basetypes.h"

extern HV* pointer_map;
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
        switch(m->action()) {
          case Marshall::FromSV:
            m->item().s_bool = SvTRUE(m->var()) ? true : false;
            break;
          case Marshall::ToSV:
            sv_setsv_mg(m->var(), boolSV(m->item().s_bool));
            break;
          default:
            m->unsupported();
            break;
        }
        break;
      case Smoke::t_int:
        switch(m->action()) {
          case Marshall::FromSV:
            m->item().s_int = (int)SvIV(m->var());
            break;
          case Marshall::ToSV:
            sv_setiv_mg(m->var(), (IV)m->item().s_int);
            break;
        }
        break;
      case Smoke::t_uint:
        marshall_it<unsigned int>(m);
        break;
      case Smoke::t_enum:
        switch(m->action()) {
          case Marshall::FromSV:
            m->item().s_enum = (long)SvIV(m->var());
            break;
          case Marshall::ToSV:
            sv_setiv_mg(m->var(), (IV)m->item().s_enum);
            break;
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
                if(!m->item().s_voidp)
                    SvSetMagicSV(m->var(), &PL_sv_undef);

                // Get return value
                void* cxxptr = m->item().s_voidp;

                // The hash
                HV *hv = newHV();
                // The hash reference to return
                SV *var = newRV_noinc((SV*)hv);

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

TypeHandler Qt_handlers[] = {
    { "QString", marshall_QString },
    { "QString&", marshall_QString },
    { "QString*", marshall_QString },
    { "const QString", marshall_QString },
    { "const QString&", marshall_QString },
    { "const QString*", marshall_QString },
    { "void", marshall_void },
    { 0, 0 }
};

Marshall::HandlerFn getMarshallFn(const SmokeType &type) {
    if(type.elem()) // If it's not t_voidp
        return marshall_basetype;
    if(!type.name())
        return marshall_void;
    if(!type_handlers) {
        return marshall_unknown;
    }
    U32 len = strlen(type.name());
    SV **svp = hv_fetch(type_handlers, type.name(), len, 0);
    if(!svp && type.isConst() && len > 6)
        svp = hv_fetch(type_handlers, type.name() + 6, len - 6, 0);
    if(svp) {
        TypeHandler *h = (TypeHandler*)SvIV(*svp);
        return h->fn;
    }
    return marshall_unknown;
}
