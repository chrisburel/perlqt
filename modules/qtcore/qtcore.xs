#include <string>
#include <vector>

#include <QMetaObject>

#include <qtcore_smoke.h>
#include "smokeobject.h"
#include "smokemanager.h"
#include "qtcore_handlers.h"

#include "perlqtmetaobject.h"

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
        SmokePerl::Object* moSmokeObj = SmokePerl::Object::fromSV(metaObject);
        QMetaObject* mo = (QMetaObject*)moSmokeObj->value;
        std::vector<std::string> arg_types;
        for (int i=0; i <= av_len(argTypes); ++i) {
            SV* item = *av_fetch(argTypes, i, 0);
            arg_types.push_back(std::string(SvPV_nolen(item)));
        }
        const char* package = mo->className();
        PerlQt5::MetaObjectManager::instance().addSlot(mo, slotName, arg_types);
        moSmokeObj->value = PerlQt5::MetaObjectManager::instance().getMetaObjectForPackage(package);

MODULE = PerlQt5::QtCore PACKAGE = PerlQt5::QtCore

BOOT:
    init_qtcore_Smoke();
    SmokePerl::SmokeManager::instance().addSmokeModule(qtcore_Smoke, "PerlQt5::QtCore");
    SmokePerl::Marshall::installHandlers(qtcore_typeHandlers);

    newXS("PerlQt5::QtCore::QObject::metaObject", XS_QOBJECT_METAOBJECT, __FILE__);
    newXS("PerlQt5::QtCore::QObject::staticMetaObject", XS_QOBJECT_STATICMETAOBJECT, __FILE__);
    newXS("PerlQt5::QtCore::Signal::connect", XS_QTCORE_SIGNAL_CONNECT, __FILE__);
