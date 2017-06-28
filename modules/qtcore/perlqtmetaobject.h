#ifndef PERLQT5_PERLQTMETAOBJECT
#define PERLQT5_PERLQTMETAOBJECT

#include <string>
#include <vector>
#include <unordered_map>

class QMetaObject;
#include <QMetaMethod>

#include <QtCore/private/qobject_p.h>

extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

#include "undoXsubDefines.h"

namespace PerlQt5 {

class MetaObjectManager {
    struct MetaObjectInfo {
        bool ownedByPerl;
        QMetaObject* metaObject;
    };

public:
    ~MetaObjectManager();

    static MetaObjectManager& instance() {
        static MetaObjectManager instance;
        return instance;
    }

    SV* getMetaObjectForPackage(const char* package);
    void addSlot(QMetaObject*& metaObject, const std::string& slotName, const std::vector<std::string>& argTypes);

    void installMetacall(QMetaObject* metaObject) const;

    MetaObjectManager(MetaObjectManager const&) = delete;
    void operator=(MetaObjectManager const&) = delete;
private:
    MetaObjectManager() {};
    std::unordered_map<std::string, MetaObjectInfo> packageToMetaObject;
};

// Ideas from qtdeclarative/src/qml/jsruntime/qv4qobjectwrapper.cpp
struct QObjectSlotDispatcher : public QtPrivate::QSlotObjectBase
{
    int signalIndex;
    QMetaMethod method;
    SV* func = nullptr;

    QObjectSlotDispatcher();

    ~QObjectSlotDispatcher();

    static void impl(int which, QSlotObjectBase *this_, QObject *r, void **metaArgs, bool *ret);
};

}

XS(XS_QOBJECT_STATICMETAOBJECT);
XS(XS_QOBJECT_METAOBJECT);
XS(XS_QOBJECT_METACALL);
XS(XS_QTCORE_SIGNAL_CONNECT);
XS(XS_QTCORE_SIGNAL_DISCONNECT);

#endif
