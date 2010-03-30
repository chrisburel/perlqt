#include "QtCore/QObject"

#include "marshall_types.h"
#include "binding.h"
#include "Qt4.h"
#include "smokeperl.h"

extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"
}

extern Q_DECL_EXPORT Smoke *qt_Smoke;
extern Q_DECL_EXPORT int do_debug;
extern Q_DECL_EXPORT QList<Smoke*> smokeList;

namespace PerlQt4 {

Binding::Binding() : SmokeBinding(0) {};
Binding::Binding(Smoke *s) : SmokeBinding(s) {};

void Binding::deleted(Smoke::Index /*classId*/, void *ptr) {
    SV* obj = getPointerObject(ptr);
    smokeperl_object* o = sv_obj_info(obj);
    if (!o || !o->ptr) {
        return;
    }
    unmapPointer( o, o->classId, 0 );

    // If it's a QObject, unmap all it's children too.
    if ( isDerivedFrom( o->smoke, o->classId, o->smoke->idClass("QObject").index, 0 ) >= 0 ) {
        QObject* objptr = (QObject*)o->smoke->cast(
            ptr,
            o->classId,
            o->smoke->idClass("QObject").index
        );
        QObjectList mychildren = objptr->children();
        foreach( QObject* child, mychildren ) {
            deleted( 0, child );
        }
    }

    o->ptr = 0;
}

bool Binding::callMethod(Smoke::Index method, void *ptr, Smoke::Stack args, bool isAbstract) {
    // If the Qt4 process forked, we want to make sure we can see the
    // interpreter
    PERL_SET_CONTEXT(PL_curinterp);
#ifdef DEBUG
    if( do_debug && (do_debug & qtdb_virtual) && (do_debug & qtdb_verbose)){
        Smoke::Method methodobj = qt_Smoke->methods[method];
        fprintf( stderr, "Looking for virtual method override for %p->%s::%s()\n",
            ptr, qt_Smoke->classes[methodobj.classId].className, qt_Smoke->methodNames[methodobj.name] );
    }
#endif
    // Look for a perl sv associated with this pointer
    SV *obj = getPointerObject(ptr);
    smokeperl_object *o = sv_obj_info(obj);

    // Didn't find one
    if(!o) {
#ifdef DEBUG
        if(!PL_dirty && (do_debug && (do_debug & qtdb_virtual) && (do_debug & qtdb_verbose)))// If not in global destruction
            fprintf(stderr, "Cannot find object for virtual method\n");
#endif
        return false;
    }

    // Now find the stash for this perl object
    HV *stash = SvSTASH(SvRV(obj));
    if(*HvNAME(stash) == ' ') // if withObject, look for a diff stash
        stash = gv_stashpv(HvNAME(stash) + 1, TRUE);

    // Get the name of the method being called
    const char *methodname = smoke->methodNames[smoke->methods[method].name];
    // Look up the autoload subroutine for that method
    GV *gv = gv_fetchmethod_autoload(stash, methodname, 0);
    // Found no autoload function
    if(!gv) return false;

#ifdef DEBUG
    if( do_debug && ( do_debug & qtdb_virtual ) )
        fprintf(stderr, "In Virtual override for %s\n", methodname);
#endif

    VirtualMethodCall call(smoke, method, args, obj, gv);
    call.next();
    return true;
}

// Args: Smoke::Index classId: the smoke classId to get the perl package name for
// Returns: char* containing the perl package name
char* Binding::className(Smoke::Index classId) {
    // Find the classId->package hash
    HV* classId2package = get_hv( "Qt4::_internal::classId2package", FALSE );
    if( !classId2package ) croak( "Internal error: Unable to find classId2package hash" );

    int smokeId = smokeList.indexOf(smoke);
    // Look up the package's name in the hash
    char* key = new char[6];
    int klen = sprintf( key, "%d", (classId<<8) + smokeId );
    //*(key + klen) = 0;
    SV** packagename = hv_fetch( classId2package, key, klen, FALSE );
    delete[] key;

    if( !packagename ) {
        // Shouldn't happen
        croak( "Internal error: Unable to resolve classId %d to perl package",
               classId );
    }

    SV* retval = sv_2mortal(newSVpvf(" %s", SvPV_nolen(*packagename)));
    return SvPV_nolen(retval);
}

} // End namespace PerlQt4
