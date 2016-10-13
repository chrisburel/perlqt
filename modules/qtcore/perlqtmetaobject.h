#ifndef PERLQT5_PERLQTMETAOBJECT
#define PERLQT5_PERLQTMETAOBJECT

#include <string>
#include <vector>
#include <unordered_map>

class QMetaObject;
#define QOBJECT_PRIVATE_HEADER QtCore/private/qobject_p.h
#include QT_STRINGIFY(PERLQT_QT_VERSION/QOBJECT_PRIVATE_HEADER)

extern "C" {
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
}

namespace PerlQt5 {

class MetaObjectManager {
public:
    static MetaObjectManager& instance() {
        static MetaObjectManager instance;
        return instance;
    }

    SV* getMetaObjectForPackage(const char* package);
    void addSlot(QMetaObject* metaObject, const std::string& slotName, const std::vector<std::string>& argTypes);

    void installMetacall(QMetaObject* metaObject) const;

    MetaObjectManager(MetaObjectManager const&) = delete;
    void operator=(MetaObjectManager const&) = delete;
private:
    MetaObjectManager() {};
    std::unordered_map<std::string, QMetaObject*> packageToMetaObject;
};

// Ideas from qtdeclarative/src/qml/jsruntime/qv4qobjectwrapper.cpp
struct QObjectSlotDispatcher : public QtPrivate::QSlotObjectBase
{
    int signalIndex;
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

#endif
