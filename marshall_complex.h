#ifndef MARSHALL_COMPLEX_H
#define MARSHALL_COMPLEX_H

//-----------------------------------------------------------------------------
template<>
void marshall_from_perl<int*>(Marshall* m) {
    SV* sv = m->var();
    if ( !SvOK(sv) ) {
        m->item().s_voidp = 0;
        return;
    }

    int* i = new int(SvIV(sv));
    m->item().s_voidp = i;
    m->next();

    if (m->cleanup() && m->type().isConst()) {
        delete i;
    }
    // Why would you do this?
    //else {
        //m->item().s_voidp = new int((int)SvIV(sv));
    //}
}

template<>
void marshall_to_perl<int*>(Marshall* m) {
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

#endif // MARSHALL_COMPLEX_H
