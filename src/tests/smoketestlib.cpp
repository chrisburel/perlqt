#include "smoketestlib.h"

QApplication* QApplication::self = nullptr;

QApplication::QApplication() {
    QApplication::self = this;
}
