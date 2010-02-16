#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include "binding.h"
#include "perlqt.h"
#include "smokeperl.h"
#include "marshall_types.h"
#include "Qt.h"

extern Q_DECL_EXPORT Smoke *qt_Smoke;
extern Q_DECL_EXPORT int do_debug;

namespace PerlQt {

Binding::Binding() : SmokeBinding(0) {};
Binding::Binding(Smoke *s) : SmokeBinding(s) {};

void Binding::deleted(Smoke::Index classId, void *ptr) {
    // Ignore deletion
}

bool Binding::callMethod(Smoke::Index method, void *ptr, Smoke::Stack args, bool isAbstract) {
    if( do_debug && (do_debug & qtdb_virtual)){
        Smoke::Method methodobj = qt_Smoke->methods[method];
        //fprintf( stderr, "Looking for virtual method override for %s::%s()\n",
        //    qt_Smoke->classes[methodobj.classId].className, qt_Smoke->methodNames[methodobj.name] );
    }
    // Look for a perl sv associated with this pointer
    SV *obj = getPointerObject(ptr);
    smokeperl_object *o = sv_obj_info(obj);

    // Didn't find one
    if(!o) {
        if(!PL_dirty && (do_debug && (do_debug & qtdb_virtual))){ // If not in global destruction
            //fprintf(stderr, "Cannot find object for virtual method\n");
        }
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

    if( do_debug && ( do_debug | qtdb_virtual ) ) {
        fprintf(stderr, "In Virtual override for %s\n", methodname);
    }

    VirtualMethodCall call(smoke, method, args, obj, gv);
    call.next();
    return true;
}

char* Binding::className(Smoke::Index classId) {
    const char *className = smoke->className(classId);
    char *buf = new char[strlen(className) + 12];
    strcpy(buf, " Qt::");
    strcat(buf, className);
    return buf;
}
} // End namespace PerlQt
