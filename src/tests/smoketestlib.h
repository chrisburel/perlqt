class QApplication {
public:
    QApplication();
    virtual ~QApplication();

    static QApplication* instance() { return self; }

private:
    static QApplication* self;

};

class VirtualMethodTester {
public:
    VirtualMethodTester() {};

    virtual const char* name() const;
    virtual const char* getName() const; // alias for name
    virtual void setName(const char* newName);

    virtual void pureVirtualMethod() = 0;

private:
    const char* m_name;
};
