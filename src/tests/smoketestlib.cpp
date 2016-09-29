#include "smoketestlib.h"

QApplication* QApplication::self = nullptr;

QApplication::QApplication() {
    QApplication::self = this;
}

QApplication::~QApplication() {
    QApplication::self = nullptr;
}

const char* VirtualMethodTester::name() const {
    return m_name;
}

const char* VirtualMethodTester::getName() const {
    return name();
}

void VirtualMethodTester::setName(const char* newName) {
    m_name = newName;
}
