#ifndef MARSHALL_COMPLEX_H
#define MARSHALL_COMPLEX_H

//-----------------------------------------------------------------------------
template <>
void marshall_from_perl<long long>(Marshall *m) {
    UNTESTED_HANDLER("marshall_from_perl<long long>");
    SV *obj = m->var();
    m->item().s_voidp = new long long;
    *(long long *)m->item().s_voidp = perl_to_primitive<long long>(obj);

    m->next();

    if(m->cleanup() && m->type().isConst()) {
        delete (long long int *) m->item().s_voidp;
    }	
}

//-----------------------------------------------------------------------------
template <>
void marshall_from_perl<unsigned long long>(Marshall *m) {
    UNTESTED_HANDLER("marshall_from_perl<unsigned long long>");
    SV *obj = m->var();
    m->item().s_voidp = new unsigned long long;
    *(long long *)m->item().s_voidp = perl_to_primitive<unsigned long long>(obj);

    m->next();

    if(m->cleanup() && m->type().isConst()) {
        delete (long long int *) m->item().s_voidp;
    }	
}

//-----------------------------------------------------------------------------
template<>
void marshall_from_perl<int*>(Marshall* m) {
    SV *sv = m->var();
    if ( !SvOK(sv) || !SvIOK(sv) ) {
        sv_setiv( sv, 0 );
    }

    // This gives us a pointer to the int stored in the perl var.
    int *i = (int*)&SvIVX( sv );
    m->item().s_voidp = i;
    m->next();

    // Don't clean up, we'd delete the perl memory.
}
template<>
void marshall_to_perl<int*>(Marshall* m) {
    UNTESTED_HANDLER("marshall_to_perl<int*>");
    int* sv = (int*)m->item().s_voidp;
    if( !sv ) {
        sv_setsv( m->var(), &PL_sv_undef );
        return;
    }

    sv_setiv( m->var(), *sv );
    m->next();
    if( !m->type().isConst() )
        *sv = SvIV(m->var());
}

//-----------------------------------------------------------------------------
template <>
void marshall_from_perl<unsigned int *>(Marshall *m) {
    UNTESTED_HANDLER("marshall_from_perl<unsigned int *>");
    SV *sv = m->var();
    unsigned int *i = new unsigned int;

    if ( !SvOK(sv) || !SvIOK(sv) ) {
        m->item().s_voidp = 0;
        return;
        //} else if (TYPE(sv) == T_OBJECT) {
        // A Qt::Integer has been passed as an integer value
        //SV *temp = rb_funcall(qt_internal_module, rb_intern("get_qinteger"), 1, sv);
        //*i = NUM2INT(temp);
        //m->item().s_voidp = i;
        //m->next();
        //rb_funcall(qt_internal_module, rb_intern("set_qinteger"), 2, sv, INT2NUM(*i));
        //sv = temp;
    } else {
        i = (unsigned int*)&SvIVX(sv);
        m->item().s_voidp = i;
        m->next();
    }

    // XXX Is this right?
    if(m->cleanup() && m->type().isConst()) {
        delete i;
    } else {
        m->item().s_voidp = new int((int)SvIV(sv));
    }
}
template <>
void marshall_to_perl<unsigned int *>(Marshall *m) {
    UNTESTED_HANDLER("marshall_to_perl<unsigned int *>");
    unsigned int *ip = (unsigned int*) m->item().s_voidp;
    SV *sv = m->var();
    if (ip == 0) {
        sv_setsv( sv, &PL_sv_undef );
        return;
    }

    sv_setiv( m->var(), *ip );
    m->next();
    if(!m->type().isConst())
        *ip = SvIV(m->var());
}

//-----------------------------------------------------------------------------
template <>
void marshall_from_perl<bool *>(Marshall *m) {
    UNTESTED_HANDLER("marshall_from_perl<bool *>");
    SV *sv = m->var();
    bool * b = new bool;

    //if (TYPE(sv) == T_OBJECT) {
    // A Qt::Boolean has been passed as a value
    //SV *temp = rb_funcall(qt_internal_module, rb_intern("get_qboolean"), 1, sv);
    //*b = (temp == Qtrue ? true : false);
    //m->item().s_voidp = b;
    //m->next();
    //rb_funcall(qt_internal_module, rb_intern("set_qboolean"), 2, sv, (*b ? Qtrue : Qfalse));
    //} else {
    *b = SvTRUE(sv);
    m->item().s_voidp = b;
    m->next();
    //}

    if(m->cleanup() && m->type().isConst()) {
        delete b;
    }
    else {
        sv_setsv( m->var(), *b ? &PL_sv_yes : & PL_sv_no );
    }
}

template <>
void marshall_to_perl<bool *>(Marshall *m) {
    UNTESTED_HANDLER("marshall_to_perl<bool *>");
    bool *ip = (bool*)m->item().s_voidp;
    if(!ip) {
        sv_setsv( m->var(), &PL_sv_undef );
        return;
    }
    sv_setiv( m->var(), *ip?1:0);
    m->next();
    if(!m->type().isConst())
        *ip = SvTRUE(m->var()) ? true : false;
}

#endif // MARSHALL_COMPLEX_H
