#ifndef MARSHALL_COMPLEX_H
#define MARSHALL_COMPLEX_H

//-----------------------------------------------------------------------------
template<>
void marshall_from_perl<int*>(Marshall* m) {
    SV* sv = m->var();
    if ( !SvOK(sv) ) {
        sv_setiv( sv, 0 );
    }

    // This should give us a pointer to the int stored in the perl var.
    // XXX May not be portable
    int* i = (int*)&((xpviv*)sv->sv_any)->xiv_u.xivu_iv;
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

#endif // MARSHALL_COMPLEX_H
