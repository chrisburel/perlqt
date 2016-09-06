#include <QString>

#include "qtcore_handlers.h"

extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

QString* qstringFromPerlString( SV* perlstring ) {
    if (SvROK(perlstring))
        perlstring = SvRV(perlstring);
    else if (!SvOK(perlstring))
        return new QString();

    switch (SvTYPE(perlstring)) {
        case SVt_PVAV:
        case SVt_PVHV:
        case SVt_PVCV:
        case SVt_PVGV:
            croak("Request to convert non scalar type to a string\n");
            break;
        default:
            break; // no error
    }
    COP* cop = cxstack[cxstack_ix].blk_oldcop;
    STRLEN len;
    char* buf = SvPV(perlstring, len);
    if (SvUTF8(perlstring))
        return new QString(QString::fromUtf8(buf, len));
    else if (cop->op_private & HINT_LOCALE)
        return new QString(QString::fromLocal8Bit(buf, len));
    else
        return new QString(QString::fromLatin1(buf, len));
}

SV* perlstringFromQString(QString* s) {
    SV* retval = newSV(0);
    COP* cop = cxstack[cxstack_ix].blk_oldcop;
    if (!(cop->op_private & HINT_BYTES)) {
        sv_setpvn(retval, s->toUtf8().constData(), s->toUtf8().length());
        SvUTF8_on(retval);
    }
    else if (cop->op_private & HINT_LOCALE)
        sv_setpvn(retval, s->toLocal8Bit().constData(), s->toLocal8Bit().length());
    else
        sv_setpvn(retval, s->toLatin1().constData(), s->toLatin1().length());
    return retval;
}

void marshall_QString(SmokePerl::Marshall* m) {
    switch(m->action()) {
        case SmokePerl::Marshall::FromSV: {
            SV* sv = m->var();
            QString* mystr = 0;

            if( SvROK( sv ) )
                sv = SvRV( sv );

            // Don't check for SvPOK.  Calling SvPV_nolen will stringify the
            // sv, which is what we want for numbers.
            mystr = qstringFromPerlString( sv );

            m->item().s_voidp = (void*)mystr;
            m->next();

            if (!m->type().isConst() && !SvREADONLY(sv) && mystr != 0) {
                sv_setsv(sv, perlstringFromQString(mystr));
            }

            if (mystr != 0 && m->cleanup()) {
                delete mystr;
            }
        }
        break;
        case SmokePerl::Marshall::ToSV: {
            QString* cxxptr = (QString*)m->item().s_voidp;
            if(cxxptr) {
                if (cxxptr->isNull()) {
                    sv_setsv(m->var(), &PL_sv_undef);
                }
                else {
                    sv_setsv(m->var(), perlstringFromQString( cxxptr ));
                }

                if (m->cleanup() || m->type().isStack() ) {
                    delete cxxptr;
                }
            }
            else {
                sv_setsv(m->var(), &PL_sv_undef);
            }
        }
        break;
        default:
            m->unsupported();
        break;
    }
}

std::unordered_map<std::string, SmokePerl::Marshall::HandlerFn> qtcore_typeHandlers {
    {"QString", marshall_QString},
    {"QString*", marshall_QString},
    {"QString&", marshall_QString},
};

