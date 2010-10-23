#ifndef VECTORFUNCTIONS_MACROS_H
#define VECTORFUNCTIONS_MACROS_H

#include <marshall_types.h>

extern QList<Smoke*> smokeList;

template <class ItemVector, class Item, const char *ItemSTR, const char* PerlName>
void XS_ItemVector_at( PerlInterpreter* my_perl , CV* cv)
{
    dXSARGS;
    if (items != 2)
       Perl_croak(aTHX_ "Usage: %s::at(array, index)", PerlName);
    PERL_UNUSED_VAR(cv); /* -W */
    {
        SV*	array = ST(0);
        int	index = (int)SvIV(ST(1));
        SV *	RETVAL;
        smokeperl_object* o = sv_obj_info(array);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        ItemVector* vector = (ItemVector*)o->ptr;
        if ( 0 > index || index > vector->size() - 1 )
            XSRETURN_UNDEF;

        Smoke::StackItem retval[1];
        retval[0].s_voidp = (void*)new Item(vector->at(index));
        Smoke::ModuleIndex typeId;
        foreach( Smoke* smoke, smokeList ) {
             if( typeId.index = smoke->idType(ItemSTR) ) {
                 typeId.smoke = smoke;
                 break;
             }
        }
        SmokeType type( typeId.smoke, typeId.index );
        PerlQt4::MethodReturnValue callreturn( typeId.smoke, retval, type );
        RETVAL = callreturn.var();
        ST(0) = RETVAL;
        // ST(0) is already mortal
    }
    XSRETURN(1);
}

template <class ItemVector, class Item, const char *ItemSTR, const char* PerlName>
void XS_ItemVector_exists( PerlInterpreter* my_perl , CV* cv)
{
    dXSARGS;
    if (items != 2)
        Perl_croak(aTHX_ "Usage: %s::exists(array, index)", PerlName);
    PERL_UNUSED_VAR(cv); /* -W */
    {
        SV*	array = ST(0);
        int	index = (int)SvIV(ST(1));
        bool	RETVAL;
        smokeperl_object* o = sv_obj_info(array);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        ItemVector* vector = (ItemVector*)o->ptr;
        if ( 0 > index || index > vector->size() - 1 )
            RETVAL = false;
        else
            RETVAL = true;
        ST(0) = boolSV(RETVAL);
        sv_2mortal(ST(0));
    }
    XSRETURN(1);
}

template <class ItemVector, const char* PerlName>
void XS_ItemVector_size( PerlInterpreter* my_perl , CV* cv)
{
    dXSARGS;
    if (items != 1)
        Perl_croak(aTHX_ "Usage: %s::size(array)", PerlName);
    PERL_UNUSED_VAR(cv); /* -W */
    {
        SV*	array = ST(0);
        int	RETVAL;
        dXSTARG;
        smokeperl_object* o = sv_obj_info(array);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        ItemVector* vector = (ItemVector*)o->ptr;
        RETVAL = vector->size();
        XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}

template <class ItemVector, class Item, const char *ItemSTR, const char* PerlName>
void XS_ItemVector_store( PerlInterpreter* my_perl , CV* cv)
{
    dXSARGS;
    if (items != 3)
        Perl_croak(aTHX_ "Usage: %s::store(array, index, value)", PerlName);
    PERL_UNUSED_VAR(cv); /* -W */
    {
        SV*	array = ST(0);
        int	index = (int)SvIV(ST(1));
        SV*	value = ST(2);
        SV *	RETVAL;
        smokeperl_object* o = sv_obj_info(array);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        smokeperl_object* valueo = sv_obj_info(value);
        if (!valueo || !valueo->ptr)
            XSRETURN_UNDEF;
        ItemVector* vector = (ItemVector*)o->ptr;
        Item* point = (Item*)valueo->ptr;

        if ( 0 > index )
            XSRETURN_UNDEF;

        while ( index > vector->size() ) {
            vector->append( Item() );
        }
        vector->append( *point );

        RETVAL = newSVsv(value);
        ST(0) = RETVAL;
        sv_2mortal(ST(0));
    }
    XSRETURN(1);
}

template <class ItemVector, class Item, const char *ItemSTR, const char* PerlName>
void XS_ItemVector_storesize( PerlInterpreter* my_perl , CV* cv)
{
    dXSARGS;
    if (items != 2)
        Perl_croak(aTHX_ "Usage: %s::storesize(array, count)", PerlName);
    PERL_UNUSED_VAR(cv); /* -W */
    PERL_UNUSED_VAR(ax); /* -Wall */
    SP -= items;
    {
        SV*	array = ST(0);
        int	count = (int)SvIV(ST(1));
        AV *	RETVAL;
        smokeperl_object* o = sv_obj_info(array);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        ItemVector* vector = (ItemVector*)o->ptr;

        vector->resize( count );
        PUTBACK;
        return;
    }
}

template <class ItemList, class Item, const char *ItemSTR, const char* PerlName>
void XS_ItemList_storesize( PerlInterpreter* my_perl , CV* cv)
{
    dXSARGS;
    if (items != 2)
        Perl_croak(aTHX_ "Usage: %s::storesize(array, count)", PerlName);
    PERL_UNUSED_VAR(cv); /* -W */
    PERL_UNUSED_VAR(ax); /* -Wall */
    SP -= items;
    {
        SV*	array = ST(0);
        int	count = (int)SvIV(ST(1));
        AV *	RETVAL;
        smokeperl_object* o = sv_obj_info(array);
        if (!o || !o->ptr || count < 0)
            XSRETURN_UNDEF;
        ItemList* vector = (ItemList*)o->ptr;

        while ( count > vector->size() )
            vector->append( Item() );
        while ( count < vector->size() )
            vector->removeLast();

        PUTBACK;
        return;
    }
}


template <class ItemVector, class Item, const char *ItemSTR, const char* PerlName>
void XS_ItemVector_delete( PerlInterpreter* my_perl , CV* cv)
{
    dXSARGS;
        if (items != 2)
            Perl_croak(aTHX_ "Usage: %s::delete(array, index)", PerlName);
    PERL_UNUSED_VAR(cv); /* -W */
    {
        SV*	array = ST(0);
        int	index = (int)SvIV(ST(1));
        SV *	RETVAL;
        smokeperl_object* o = sv_obj_info(array);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        ItemVector* vector = (ItemVector*)o->ptr;

        Smoke::StackItem retval[1];
        retval[0].s_voidp = (void*)new Item(vector->at(index));

        vector->replace( index, Item() );

        Smoke::ModuleIndex typeId;
        foreach( Smoke* smoke, smokeList ) {
             if( typeId.index = smoke->idType(ItemSTR) ) {
                 typeId.smoke = smoke;
                 break;
             }
        }
        SmokeType type( typeId.smoke, typeId.index );
        PerlQt4::MethodReturnValue callreturn( typeId.smoke, retval, type );
        RETVAL = callreturn.var();

        ST(0) = RETVAL;
        sv_2mortal(ST(0));
    }
    XSRETURN(1);
}


template <class ItemVector, class Item, const char *ItemSTR, const char* PerlName>
void XS_ItemVector_clear( PerlInterpreter* my_perl , CV* cv)
{
    dXSARGS;
        if (items != 1)
            Perl_croak(aTHX_ "Usage: %s::clear(array)", PerlName);
    PERL_UNUSED_VAR(cv); /* -W */
    {
        SV*	array = ST(0);
        smokeperl_object* o = sv_obj_info(array);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        ItemVector* vector = (ItemVector*)o->ptr;

        vector->clear();
    }
    XSRETURN_EMPTY;
}


template <class ItemVector, class Item, const char *ItemSTR, const char* PerlName>
void XS_ItemVector_push( PerlInterpreter* my_perl , CV* cv)
{
    dXSARGS;
        if (items < 1)
            Perl_croak(aTHX_ "Usage: %s::push(array, ...)", PerlName);
    PERL_UNUSED_VAR(cv); /* -W */
    {
        SV*	array = ST(0);
        int	RETVAL;
        dXSTARG;
        smokeperl_object* o = sv_obj_info(array);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        ItemVector* vector = (ItemVector*)o->ptr;

        for( int i = 1; i < items; ++i ) {
            smokeperl_object *arg = sv_obj_info(ST(i));
            if (!arg || !arg->ptr)
                continue;
            Item* point = (Item*)arg->ptr;
            vector->append( *point );
        }
        RETVAL = vector->size();
        XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}


template <class ItemVector, class Item, const char *ItemSTR, const char* PerlName>
void XS_ItemVector_pop( PerlInterpreter* my_perl , CV* cv)
{
    dXSARGS;
        if (items != 1)
            Perl_croak(aTHX_ "Usage: %s::pop(array)", PerlName);
    PERL_UNUSED_VAR(cv); /* -W */
    {
        SV*	array = ST(0);
        SV *	RETVAL;
        smokeperl_object* o = sv_obj_info(array);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        ItemVector* vector = (ItemVector*)o->ptr;

        Smoke::StackItem retval[1];
        retval[0].s_voidp = (void*)new Item(vector->last());

        Smoke::ModuleIndex typeId;
        foreach( Smoke* smoke, smokeList ) {
             if( typeId.index = smoke->idType(ItemSTR) ) {
                 typeId.smoke = smoke;
                 break;
             }
        }
        SmokeType type( typeId.smoke, typeId.index );
        PerlQt4::MethodReturnValue callreturn( typeId.smoke, retval, type );
        RETVAL = callreturn.var();

        vector->pop_back();
        ST(0) = RETVAL;
        sv_2mortal(ST(0));
    }
    XSRETURN(1);
}


template <class ItemVector, class Item, const char *ItemSTR, const char* PerlName>
void XS_ItemVector_shift( PerlInterpreter* my_perl , CV* cv)
{
    dXSARGS;
        if (items != 1)
            Perl_croak(aTHX_ "Usage: %s::shift(array)", PerlName);
    PERL_UNUSED_VAR(cv); /* -W */
    {
        SV*	array = ST(0);
        SV *	RETVAL;
        smokeperl_object* o = sv_obj_info(array);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        ItemVector* vector = (ItemVector*)o->ptr;

        if ( vector->size() == 0 )
            XSRETURN_UNDEF;

        Smoke::StackItem retval[1];
        retval[0].s_voidp = (void*)new Item(vector->first());
        Smoke::ModuleIndex typeId;
        foreach( Smoke* smoke, smokeList ) {
             if( typeId.index = smoke->idType(ItemSTR) ) {
                 typeId.smoke = smoke;
                 break;
             }
        }
        SmokeType type( typeId.smoke, typeId.index );
        PerlQt4::MethodReturnValue callreturn( typeId.smoke, retval, type );
        RETVAL = callreturn.var();
        vector->pop_front();
        ST(0) = RETVAL;
        sv_2mortal(ST(0));
    }
    XSRETURN(1);
}


template <class ItemVector, class Item, const char *ItemSTR, const char* PerlName>
void XS_ItemVector_unshift( PerlInterpreter* my_perl , CV* cv)
{
    dXSARGS;
        if (items < 1)
            Perl_croak(aTHX_ "Usage: %s::unshift(array, ...)", PerlName);
    PERL_UNUSED_VAR(cv); /* -W */
    {
        SV*	array = ST(0);
        int	RETVAL;
        dXSTARG;
        smokeperl_object* o = sv_obj_info(array);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        ItemVector* vector = (ItemVector*)o->ptr;

        for( int i = items-1; i >= 1; --i ) {
            smokeperl_object *arg = sv_obj_info(ST(i));
            if (!arg || !arg->ptr)
                continue;
            Item* point = (Item*)arg->ptr;
            vector->insert( 0, *point );
        }
        RETVAL = vector->size();
        XSprePUSH; PUSHi((IV)RETVAL);
    }
    XSRETURN(1);
}


template <class ItemVector, class Item, const char *ItemSTR, const char* PerlName>
void XS_ItemVector_splice( PerlInterpreter* my_perl , CV* cv)
{
    dXSARGS;
        if (items < 1)
            Perl_croak(aTHX_ "Usage: %s::splice(array, firstIndex = 0, length = -1, ...)", PerlName);
    PERL_UNUSED_VAR(cv); /* -W */
    {
        SV*	array = ST(0);
        int	firstIndex;
        int	length;

        if (items < 2)
            firstIndex = 0;
        else {
            firstIndex = (int)SvIV(ST(1));
        }

        if (items < 3)
            length = -1;
        else {
            length = (int)SvIV(ST(2));
        }
        smokeperl_object* o = sv_obj_info(array);
        if (!o || !o->ptr)
            XSRETURN_UNDEF;
        ItemVector* vector = (ItemVector*)o->ptr;

        if ( firstIndex > vector->size() )
            firstIndex = vector->size();

        if ( length == -1 )
            length = vector->size()-firstIndex;

        int lastIndex = firstIndex + length;

        AV* args = newAV();
        for( int i = 3; i < items; ++i ) {
            av_push(args, ST(i));
        }

        EXTEND(SP, length);

        Smoke::ModuleIndex mi = Smoke::classMap[ItemSTR];
        for( int i = firstIndex, j = 0; i < lastIndex; ++i, ++j ) {
            Item* point = new Item(vector->at(firstIndex));

            smokeperl_object* reto = alloc_smokeperl_object(
                    true, mi.smoke, mi.index, (void*)point );
            const char* classname = perlqt_modules[reto->smoke].resolve_classname(reto);
            SV* retval = set_obj_info( classname, reto );
            point = (Item*)sv_obj_info(retval)->ptr;
            ST(j) = retval;
            vector->remove(firstIndex);
        }

        for( int i = items-4; i >= 0; --i ) {
            Item* point = (Item*)(sv_obj_info(av_pop(args))->ptr);
            vector->insert(firstIndex, *point);
        }

        XSRETURN( length );
    }
    XSRETURN(1);
}


template <class ItemVector, class Item, const char *ItemSTR, const char* PerlName, const char *ItemVectorSTR>
void XS_ItemVector__overload_op_equality( PerlInterpreter* my_perl , CV* cv)
{
    dXSARGS;
        if (items != 3)
            Perl_croak(aTHX_ "Usage: %s::operator=(first, second, reversed)", PerlName);
    PERL_UNUSED_VAR(cv); /* -W */
    {
        SV*	first = ST(0);
        SV*	second = ST(1);
        bool	RETVAL;
        smokeperl_object* o1 = sv_obj_info(first);
        if (!o1 || !o1->ptr)
            XSRETURN_UNDEF;
        ItemVector* list1 = (ItemVector*)o1->ptr;

        smokeperl_object* o2 = sv_obj_info(second);
        if (!o2 || !o2->ptr || isDerivedFrom(o2, ItemVectorSTR) == -1)
            XSRETURN_UNDEF;
        ItemVector* list2 = (ItemVector*)o2->ptr;

        RETVAL = *list1 == *list2;
        ST(0) = boolSV(RETVAL);
        sv_2mortal(ST(0));
    }
    XSRETURN(1);
}

#define DEF_VECTORCLASS_FUNCTIONS(ItemVector,Item,PerlName) \
namespace { \
char ItemVector##STR[] = #ItemVector;\
char Item##STR[] = #Item;\
char Item##PerlNameSTR[] = #PerlName;\
void (*XS_##ItemVector##_at)(PerlInterpreter*, CV*)                    = XS_ItemVector_at<ItemVector, Item, Item##STR, Item##PerlNameSTR>;\
void (*XS_##ItemVector##_exists)(PerlInterpreter*, CV*)                = XS_ItemVector_exists<ItemVector, Item, Item##STR, Item##PerlNameSTR>;\
void (*XS_##ItemVector##_size)(PerlInterpreter*, CV*)                  = XS_ItemVector_size<ItemVector, Item##PerlNameSTR>;\
void (*XS_##ItemVector##_store)(PerlInterpreter*, CV*)                 = XS_ItemVector_store<ItemVector, Item, Item##STR, Item##PerlNameSTR>;\
void (*XS_##ItemVector##_storesize)(PerlInterpreter*, CV*)             = XS_ItemVector_storesize<ItemVector, Item, Item##STR, Item##PerlNameSTR>;\
void (*XS_##ItemVector##_delete)(PerlInterpreter*, CV*)                = XS_ItemVector_delete<ItemVector, Item, Item##STR, Item##PerlNameSTR>;\
void (*XS_##ItemVector##_clear)(PerlInterpreter*, CV*)                 = XS_ItemVector_clear<ItemVector, Item, Item##STR, Item##PerlNameSTR>;\
void (*XS_##ItemVector##_push)(PerlInterpreter*, CV*)                  = XS_ItemVector_push<ItemVector, Item, Item##STR, Item##PerlNameSTR>;\
void (*XS_##ItemVector##_pop)(PerlInterpreter*, CV*)                   = XS_ItemVector_pop<ItemVector, Item, Item##STR, Item##PerlNameSTR>;\
void (*XS_##ItemVector##_shift)(PerlInterpreter*, CV*)                 = XS_ItemVector_shift<ItemVector, Item, Item##STR, Item##PerlNameSTR>;\
void (*XS_##ItemVector##_unshift)(PerlInterpreter*, CV*)               = XS_ItemVector_unshift<ItemVector, Item, Item##STR, Item##PerlNameSTR>;\
void (*XS_##ItemVector##_splice)(PerlInterpreter*, CV*)                = XS_ItemVector_splice<ItemVector, Item, Item##STR, Item##PerlNameSTR>;\
void (*XS_##ItemVector##__overload_op_equality)(PerlInterpreter*, CV*) = XS_ItemVector__overload_op_equality<ItemVector, Item, Item##STR, Item##PerlNameSTR, ItemVector##STR>;\
\
}

#define DEF_LISTCLASS_FUNCTIONS(ItemList,Item,ItemName,PerlName) \
namespace { \
char ItemList##STR[] = #ItemList;\
char ItemName##STR[] = #Item;\
char ItemName##PerlNameSTR[] = #PerlName;\
void (*XS_##ItemList##_at)(PerlInterpreter*, CV*)                    = XS_ItemVector_at<ItemList, Item, ItemName##STR, ItemName##PerlNameSTR>;\
void (*XS_##ItemList##_exists)(PerlInterpreter*, CV*)                = XS_ItemVector_exists<ItemList, Item, ItemName##STR, ItemName##PerlNameSTR>;\
void (*XS_##ItemList##_size)(PerlInterpreter*, CV*)                  = XS_ItemVector_size<ItemList, ItemName##PerlNameSTR>;\
void (*XS_##ItemList##_store)(PerlInterpreter*, CV*)                 = XS_ItemVector_store<ItemList, Item, ItemName##STR, ItemName##PerlNameSTR>;\
void (*XS_##ItemList##_storesize)(PerlInterpreter*, CV*)             = XS_ItemList_storesize<ItemList, Item, ItemName##STR, ItemName##PerlNameSTR>;\
void (*XS_##ItemList##_delete)(PerlInterpreter*, CV*)                = XS_ItemVector_delete<ItemList, Item, ItemName##STR, ItemName##PerlNameSTR>;\
void (*XS_##ItemList##_clear)(PerlInterpreter*, CV*)                 = XS_ItemVector_clear<ItemList, Item, ItemName##STR, ItemName##PerlNameSTR>;\
void (*XS_##ItemList##_push)(PerlInterpreter*, CV*)                  = XS_ItemVector_push<ItemList, Item, ItemName##STR, ItemName##PerlNameSTR>;\
void (*XS_##ItemList##_shift)(PerlInterpreter*, CV*)                 = XS_ItemVector_shift<ItemList, Item, ItemName##STR, ItemName##PerlNameSTR>;\
void (*XS_##ItemList##_unshift)(PerlInterpreter*, CV*)               = XS_ItemVector_unshift<ItemList, Item, ItemName##STR, ItemName##PerlNameSTR>;\
void (*XS_##ItemList##__overload_op_equality)(PerlInterpreter*, CV*) = XS_ItemVector__overload_op_equality<ItemList, Item, ItemName##STR, ItemName##PerlNameSTR, ItemList##STR>;\
\
}

#endif
