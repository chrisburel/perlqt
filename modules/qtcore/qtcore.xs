#include <string>
#include <vector>
#include <qtcore_smoke.h>
#include "smokeobject.h"
#include "smokemanager.h"
#include "qtcore_handlers.h"

#include "perlqtinit.h"
#include "perlqtmetaobject.h"

class QMetaObject;

// Perl headers
extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

MODULE = PerlQt5::QtCore::_internal PACKAGE = PerlQt5::QtCore::_internal

void addSlot(metaObject, slotName, argTypes)
        SV* metaObject
        const char* slotName
        AV* argTypes
    CODE:
        QMetaObject* mo = (QMetaObject*)SmokePerl::Object::fromSV(metaObject)->value;
        std::vector<std::string> arg_types;
        for (int i=0; i <= av_len(argTypes); ++i) {
            SV* item = *av_fetch(argTypes, i, 0);
            arg_types.push_back(std::string(SvPV_nolen(item)));
        }
        PerlQt5::MetaObjectManager::instance().addSlot(mo, slotName, arg_types);

MODULE = PerlQt5::QtCore PACKAGE = PerlQt5::QtCore

BOOT:
    init_qtcore_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtcore_Smoke, "PerlQt5::QtCore");
    SmokePerl::Marshall::installHandlers(qtcore_typeHandlers);
    PerlQt5::initSmokeModule(qtcore_Smoke, "PerlQt5::QtCore");
