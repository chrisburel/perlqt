#ifndef VECTORFUNCTIONS_MACROS_H
#define VECTORFUNCTIONS_MACROS_H

#include <marshall_types.h>

#define DEF_VECTORCLASS_FUNCTIONS(ItemVector,Item,PerlName) \
XS(XS_##ItemVector##_at); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemVector##_at) \
{ \
    dXSARGS; \
    if (items != 2) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::at", "array, index"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	int	index = (int)SvIV(ST(1)); \
	SV *	RETVAL; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemVector* vector = (ItemVector*)o->ptr; \
        if ( 0 > index || index > vector->size() - 1 ) \
            XSRETURN_UNDEF; \
        Item* point = new Item(vector->at(index)); \
        Smoke::ModuleIndex mi = Smoke::classMap[#Item]; \
        smokeperl_object* reto = alloc_smokeperl_object( \
            true, mi.smoke, mi.index, (void*)point ); \
        const char* classname = perlqt_modules[reto->smoke].resolve_classname(reto); \
        RETVAL = set_obj_info( classname, reto ); \
	ST(0) = RETVAL; \
	sv_2mortal(ST(0)); \
    } \
    XSRETURN(1); \
} \
 \
XS(XS_##ItemVector##_exists); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemVector##_exists) \
{ \
    dXSARGS;\
    if (items != 2) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::exists", "array, index"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	int	index = (int)SvIV(ST(1)); \
	bool	RETVAL; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemVector* vector = (ItemVector*)o->ptr; \
        if ( 0 > index || index > vector->size() - 1 ) \
            RETVAL = false; \
        else \
            RETVAL = true; \
	ST(0) = boolSV(RETVAL); \
	sv_2mortal(ST(0)); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemVector##_size); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemVector##_size) \
{ \
    dXSARGS;\
    if (items != 1) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::size", "array"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	int	RETVAL; \
	dXSTARG; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemVector* vector = (ItemVector*)o->ptr; \
        RETVAL = vector->size(); \
	XSprePUSH; PUSHi((IV)RETVAL); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemVector##_store); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemVector##_store) \
{ \
    dXSARGS;\
    if (items != 3) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::store", "array, index, value"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	int	index = (int)SvIV(ST(1)); \
	SV*	value = ST(2); \
	SV *	RETVAL; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        smokeperl_object* valueo = sv_obj_info(value); \
        if (!valueo || !valueo->ptr) \
            XSRETURN_UNDEF; \
        ItemVector* vector = (ItemVector*)o->ptr; \
        Item* point = (Item*)valueo->ptr; \
 \
        if ( 0 > index ) \
            XSRETURN_UNDEF; \
 \
        while ( index > vector->size() ) { \
            vector->append( Item() ); \
        } \
        vector->append( *point ); \
 \
        RETVAL = newSVsv(value); \
	ST(0) = RETVAL; \
	sv_2mortal(ST(0)); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemVector##_storesize); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemVector##_storesize) \
{ \
    dXSARGS;\
    if (items != 2) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::storesize", "array, count"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    PERL_UNUSED_VAR(ax); /* -Wall */ \
    SP -= items; \
    { \
	SV*	array = ST(0); \
	int	count = (int)SvIV(ST(1)); \
	AV *	RETVAL; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemVector* vector = (ItemVector*)o->ptr; \
 \
        vector->resize( count ); \
	PUTBACK; \
	return; \
    } \
} \
 \
 \
XS(XS_##ItemVector##_delete); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemVector##_delete) \
{ \
    dXSARGS;\
    if (items != 2) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::delete", "array, index"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	int	index = (int)SvIV(ST(1)); \
	SV *	RETVAL; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemVector* vector = (ItemVector*)o->ptr; \
 \
        Item* point = new Item(vector->at(index)); \
 \
        vector->replace( index, Item() ); \
 \
        Smoke::ModuleIndex mi = Smoke::classMap[#Item]; \
        smokeperl_object* reto = alloc_smokeperl_object( \
            true, mi.smoke, mi.index, (void*)point ); \
        const char* classname = perlqt_modules[reto->smoke].resolve_classname(reto); \
        RETVAL = set_obj_info( classname, reto ); \
	ST(0) = RETVAL; \
	sv_2mortal(ST(0)); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemVector##_clear); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemVector##_clear) \
{ \
    dXSARGS;\
    if (items != 1) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::clear", "array"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemVector* vector = (ItemVector*)o->ptr; \
 \
        vector->clear(); \
    } \
    XSRETURN_EMPTY; \
} \
 \
 \
XS(XS_##ItemVector##_push); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemVector##_push) \
{ \
    dXSARGS;\
    if (items < 1) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::push", "array, ..."); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	int	RETVAL; \
	dXSTARG; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemVector* vector = (ItemVector*)o->ptr; \
 \
        for( int i = 1; i < items; ++i ) { \
            smokeperl_object *arg = sv_obj_info(ST(i)); \
            if (!arg || !arg->ptr) \
                continue; \
            Item* point = (Item*)arg->ptr; \
            vector->append( *point ); \
        } \
        RETVAL = vector->size(); \
	XSprePUSH; PUSHi((IV)RETVAL); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemVector##_pop); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemVector##_pop) \
{ \
    dXSARGS;\
    if (items != 1) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::pop", "array"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	SV *	RETVAL; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemVector* vector = (ItemVector*)o->ptr; \
 \
        Item* point = new Item(vector->last()); \
        Smoke::ModuleIndex mi = Smoke::classMap[#Item]; \
        smokeperl_object* reto = alloc_smokeperl_object( \
            true, mi.smoke, mi.index, (void*)point ); \
        const char* classname = perlqt_modules[reto->smoke].resolve_classname(reto); \
        RETVAL = set_obj_info( classname, reto ); \
        vector->remove(vector->size()-1); \
	ST(0) = RETVAL; \
	sv_2mortal(ST(0)); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemVector##_shift); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemVector##_shift) \
{ \
    dXSARGS;\
    if (items != 1) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::shift", "array"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	SV *	RETVAL; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemVector* vector = (ItemVector*)o->ptr; \
 \
        Item* point = new Item(vector->first()); \
        Smoke::ModuleIndex mi = Smoke::classMap[#Item]; \
        smokeperl_object* reto = alloc_smokeperl_object( \
            true, mi.smoke, mi.index, (void*)point ); \
        const char* classname = perlqt_modules[reto->smoke].resolve_classname(reto); \
        RETVAL = set_obj_info( classname, reto ); \
        vector->remove(0); \
	ST(0) = RETVAL; \
	sv_2mortal(ST(0)); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemVector##_unshift); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemVector##_unshift) \
{ \
    dXSARGS;\
    if (items < 1) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::unshift", "array, ..."); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	int	RETVAL; \
	dXSTARG; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemVector* vector = (ItemVector*)o->ptr; \
 \
        for( int i = items-1; i >= 1; --i ) { \
            smokeperl_object *arg = sv_obj_info(ST(i)); \
            if (!arg || !arg->ptr) \
                continue; \
            Item* point = (Item*)arg->ptr; \
            vector->insert( 0, *point ); \
        } \
        RETVAL = vector->size(); \
	XSprePUSH; PUSHi((IV)RETVAL); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemVector##_splice); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemVector##_splice) \
{ \
    dXSARGS;\
    if (items < 1) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::splice", "array, firstIndex = 0, length = -1, ..."); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	int	firstIndex; \
	int	length; \
 \
	if (items < 2) \
	    firstIndex = 0; \
	else { \
	    firstIndex = (int)SvIV(ST(1)); \
	} \
 \
	if (items < 3) \
	    length = -1; \
	else { \
	    length = (int)SvIV(ST(2)); \
	} \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemVector* vector = (ItemVector*)o->ptr; \
 \
        if ( firstIndex > vector->size() ) \
            firstIndex = vector->size(); \
 \
        if ( length == -1 ) \
            length = vector->size()-firstIndex; \
 \
        int lastIndex = firstIndex + length; \
 \
        AV* args = newAV(); \
        for( int i = 3; i < items; ++i ) { \
            av_push(args, ST(i)); \
        } \
 \
        EXTEND(SP, length); \
 \
        Smoke::ModuleIndex mi = Smoke::classMap[#Item]; \
        for( int i = firstIndex, j = 0; i < lastIndex; ++i, ++j ) { \
            Item* point = new Item(vector->at(firstIndex)); \
 \
            smokeperl_object* reto = alloc_smokeperl_object( \
                    true, mi.smoke, mi.index, (void*)point ); \
            const char* classname = perlqt_modules[reto->smoke].resolve_classname(reto); \
            SV* retval = set_obj_info( classname, reto ); \
            point = (Item*)sv_obj_info(retval)->ptr; \
            ST(j) = retval; \
            vector->remove(firstIndex); \
        } \
 \
        for( int i = items-4; i >= 0; --i ) { \
            Item* point = (Item*)(sv_obj_info(av_pop(args))->ptr); \
            vector->insert(firstIndex, *point); \
        } \
 \
        XSRETURN( length ); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemVector##___overload_op_equality); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemVector##___overload_op_equality) \
{ \
    dXSARGS;\
    if (items != 3) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::_overload::op_equality", "first, second, reversed"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	first = ST(0); \
	SV*	second = ST(1); \
	bool	RETVAL; \
        smokeperl_object* o1 = sv_obj_info(first); \
        if (!o1 || !o1->ptr) \
            XSRETURN_UNDEF; \
        ItemVector* list1 = (ItemVector*)o1->ptr; \
 \
        smokeperl_object* o2 = sv_obj_info(second); \
        if (!o2 || !o2->ptr || isDerivedFrom(o2, #ItemVector) == -1) \
            XSRETURN_UNDEF; \
        ItemVector* list2 = (ItemVector*)o2->ptr; \
 \
        RETVAL = *list1 == *list2; \
	ST(0) = boolSV(RETVAL); \
	sv_2mortal(ST(0)); \
    } \
    XSRETURN(1); \
} \

#define DEF_LISTCLASS_FUNCTIONS(ItemList,Item,PerlName) \
XS(XS_##ItemList##_at); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemList##_at) \
{ \
    dXSARGS; \
    if (items != 2) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::at", "array, index"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	int	index = (int)SvIV(ST(1)); \
	SV *	RETVAL; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemList* list = (ItemList*)o->ptr; \
        if ( 0 > index || index > list->size() - 1 ) \
            XSRETURN_UNDEF; \
        Smoke::StackItem retval[1]; \
        retval[0].s_voidp = (void*)new Item(list->at(index)); \
        Smoke::ModuleIndex typeId;\
        foreach( Smoke* smoke, smokeList ) { \
             if( typeId.index = smoke->idType(#Item) ) { \
                 typeId.smoke = smoke; \
                 break; \
             } \
        } \
        SmokeType type( typeId.smoke, typeId.index ); \
        PerlQt4::MethodReturnValue callreturn( typeId.smoke, retval, type ); \
        RETVAL = callreturn.var(); \
	ST(0) = RETVAL; \
	sv_2mortal(ST(0)); \
    } \
    XSRETURN(1); \
} \
 \
XS(XS_##ItemList##_exists); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemList##_exists) \
{ \
    dXSARGS;\
    if (items != 2) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::exists", "array, index"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	int	index = (int)SvIV(ST(1)); \
	bool	RETVAL; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemList* list = (ItemList*)o->ptr; \
        if ( 0 > index || index > list->size() - 1 ) \
            RETVAL = false; \
        else \
            RETVAL = true; \
	ST(0) = boolSV(RETVAL); \
	sv_2mortal(ST(0)); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemList##_size); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemList##_size) \
{ \
    dXSARGS;\
    if (items != 1) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::size", "array"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	int	RETVAL; \
	dXSTARG; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemList* list = (ItemList*)o->ptr; \
        RETVAL = list->size(); \
	XSprePUSH; PUSHi((IV)RETVAL); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemList##_store); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemList##_store) \
{ \
    dXSARGS;\
    if (items != 3) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::store", "array, index, value"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	int	index = (int)SvIV(ST(1)); \
	SV*	value = ST(2); \
	SV *	RETVAL; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        smokeperl_object* valueo = sv_obj_info(value); \
        if (!valueo || !valueo->ptr) \
            XSRETURN_UNDEF; \
        ItemList* list = (ItemList*)o->ptr; \
        Item* point = (Item*)valueo->ptr; \
 \
        if ( 0 > index ) \
            XSRETURN_UNDEF; \
 \
        while ( index > list->size() ) { \
            list->append( Item() ); \
        } \
        list->append( *point ); \
 \
        RETVAL = newSVsv(value); \
	ST(0) = RETVAL; \
	sv_2mortal(ST(0)); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemList##_storesize); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemList##_storesize) \
{ \
    dXSARGS;\
    if (items != 2) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::storesize", "array, count"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    PERL_UNUSED_VAR(ax); /* -Wall */ \
    SP -= items; \
    { \
	SV*	array = ST(0); \
	int	count = (int)SvIV(ST(1)); \
	AV *	RETVAL; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemList* list = (ItemList*)o->ptr; \
 \
        while ( count > list->size() ) { \
            list->append( Item() ); \
        } \
	PUTBACK; \
	return; \
    } \
} \
 \
 \
XS(XS_##ItemList##_delete); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemList##_delete) \
{ \
    dXSARGS;\
    if (items != 2) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::delete", "array, index"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	int	index = (int)SvIV(ST(1)); \
	SV *	RETVAL; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemList* list = (ItemList*)o->ptr; \
 \
        Smoke::StackItem retval[1]; \
        retval[0].s_voidp = (void*)new Item(list->at(index)); \
        list->replace( index, Item() ); \
        Smoke::ModuleIndex typeId;\
        foreach( Smoke* smoke, smokeList ) { \
             if( typeId.index = smoke->idType(#Item) ) { \
                 typeId.smoke = smoke; \
                 break; \
             } \
        } \
        SmokeType type( typeId.smoke, typeId.index ); \
        PerlQt4::MethodReturnValue callreturn( typeId.smoke, retval, type ); \
        RETVAL = callreturn.var(); \
	ST(0) = RETVAL; \
	sv_2mortal(ST(0)); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemList##_clear); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemList##_clear) \
{ \
    dXSARGS;\
    if (items != 1) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::clear", "array"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemList* list = (ItemList*)o->ptr; \
 \
        list->clear(); \
    } \
    XSRETURN_EMPTY; \
} \
 \
 \
XS(XS_##ItemList##_push); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemList##_push) \
{ \
    dXSARGS;\
    if (items < 1) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::push", "array, ..."); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	int	RETVAL; \
	dXSTARG; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemList* list = (ItemList*)o->ptr; \
 \
        for( int i = 1; i < items; ++i ) { \
            smokeperl_object *arg = sv_obj_info(ST(i)); \
            if (!arg || !arg->ptr) \
                continue; \
            Item* point = (Item*)arg->ptr; \
            list->append( *point ); \
        } \
        RETVAL = list->size(); \
	XSprePUSH; PUSHi((IV)RETVAL); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemList##_pop); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemList##_pop) \
{ \
    dXSARGS;\
    if (items != 1) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::pop", "array"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	SV *	RETVAL; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemList* list = (ItemList*)o->ptr; \
 \
        Smoke::StackItem retval[1]; \
        retval[0].s_voidp = (void*)new Item(list->first()); \
        Smoke::ModuleIndex typeId;\
        foreach( Smoke* smoke, smokeList ) { \
             if( typeId.index = smoke->idType(#Item) ) { \
                 typeId.smoke = smoke; \
                 break; \
             } \
        } \
        SmokeType type( typeId.smoke, typeId.index ); \
        PerlQt4::MethodReturnValue callreturn( typeId.smoke, retval, type ); \
        RETVAL = callreturn.var(); \
        list->removeLast(); \
	ST(0) = RETVAL; \
	sv_2mortal(ST(0)); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemList##_shift); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemList##_shift) \
{ \
    dXSARGS;\
    if (items != 1) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::shift", "array"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	SV *	RETVAL; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemList* list = (ItemList*)o->ptr; \
        if ( list->size() == 0 ) \
            XSRETURN_UNDEF; \
 \
        Smoke::StackItem retval[1]; \
        retval[0].s_voidp = (void*)new Item(list->first()); \
        Smoke::ModuleIndex typeId;\
        foreach( Smoke* smoke, smokeList ) { \
             if( typeId.index = smoke->idType(#Item) ) { \
                 typeId.smoke = smoke; \
                 break; \
             } \
        } \
        SmokeType type( typeId.smoke, typeId.index ); \
        PerlQt4::MethodReturnValue callreturn( typeId.smoke, retval, type ); \
        RETVAL = callreturn.var(); \
        list->removeFirst(); \
	ST(0) = RETVAL; \
	sv_2mortal(ST(0)); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemList##_unshift); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemList##_unshift) \
{ \
    dXSARGS;\
    if (items < 1) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::unshift", "array, ..."); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	int	RETVAL; \
	dXSTARG; \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemList* list = (ItemList*)o->ptr; \
 \
        for( int i = items-1; i >= 1; --i ) { \
            smokeperl_object *arg = sv_obj_info(ST(i)); \
            if (!arg || !arg->ptr) \
                continue; \
            Item* point = (Item*)arg->ptr; \
            list->insert( 0, *point ); \
        } \
        RETVAL = list->size(); \
	XSprePUSH; PUSHi((IV)RETVAL); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemList##_splice); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemList##_splice) \
{ \
    dXSARGS;\
    if (items < 1) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::splice", "array, firstIndex = 0, length = -1, ..."); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	array = ST(0); \
	int	firstIndex; \
	int	length; \
 \
	if (items < 2) \
	    firstIndex = 0; \
	else { \
	    firstIndex = (int)SvIV(ST(1)); \
	} \
 \
	if (items < 3) \
	    length = -1; \
	else { \
	    length = (int)SvIV(ST(2)); \
	} \
        smokeperl_object* o = sv_obj_info(array); \
        if (!o || !o->ptr) \
            XSRETURN_UNDEF; \
        ItemList* list = (ItemList*)o->ptr; \
 \
        if ( firstIndex > list->size() ) \
            firstIndex = list->size(); \
 \
        if ( length == -1 ) \
            length = list->size()-firstIndex; \
 \
        int lastIndex = firstIndex + length; \
 \
        AV* args = newAV(); \
        for( int i = 3; i < items; ++i ) { \
            av_push(args, ST(i)); \
        } \
 \
        EXTEND(SP, length); \
 \
        Smoke::ModuleIndex mi = Smoke::classMap[#Item]; \
        for( int i = firstIndex, j = 0; i < lastIndex; ++i, ++j ) { \
            Item* point = new Item(list->at(firstIndex)); \
 \
            smokeperl_object* reto = alloc_smokeperl_object( \
                    true, mi.smoke, mi.index, (void*)point ); \
            const char* classname = perlqt_modules[reto->smoke].resolve_classname(reto); \
            SV* retval = set_obj_info( classname, reto ); \
            point = (Item*)sv_obj_info(retval)->ptr; \
            ST(j) = retval; \
            list->removeAt(firstIndex); \
        } \
 \
        for( int i = items-4; i >= 0; --i ) { \
            Item* point = (Item*)(sv_obj_info(av_pop(args))->ptr); \
            list->insert(firstIndex, *point); \
        } \
 \
        XSRETURN( length ); \
    } \
    XSRETURN(1); \
} \
 \
 \
XS(XS_##ItemList##___overload_op_equality); /* prototype to pass -Wmissing-prototypes */ \
XS(XS_##ItemList##___overload_op_equality) \
{ \
    dXSARGS;\
    if (items != 3) \
       Perl_croak(aTHX_ "Usage: %s(%s)", "PerlName##::_overload::op_equality", "first, second, reversed"); \
    PERL_UNUSED_VAR(cv); /* -W */ \
    { \
	SV*	first = ST(0); \
	SV*	second = ST(1); \
	bool	RETVAL; \
        smokeperl_object* o1 = sv_obj_info(first); \
        if (!o1 || !o1->ptr) \
            XSRETURN_UNDEF; \
        ItemList* list1 = (ItemList*)o1->ptr; \
 \
        smokeperl_object* o2 = sv_obj_info(second); \
        if (!o2 || !o2->ptr || isDerivedFrom(o2, #ItemList) == -1) \
            XSRETURN_UNDEF; \
        ItemList* list2 = (ItemList*)o2->ptr; \
 \
        RETVAL = *list1 == *list2; \
	ST(0) = boolSV(RETVAL); \
	sv_2mortal(ST(0)); \
    } \
    XSRETURN(1); \
} \

#endif
