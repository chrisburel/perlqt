#if defined (_WIN32)
    #if defined(smoketestlib_EXPORTS)
        #define SMOKETESTLIB_EXPORT __declspec(dllexport)
    #else
        #define SMOKETESTLIB_EXPORT __declspec(dllimport)
    #endif
#else
    #define SMOKETESTLIB_EXPORT
#endif

class SMOKETESTLIB_EXPORT QApplication {
public:
    QApplication();
    virtual ~QApplication();

    static QApplication* instance() { return self; }

private:
    static QApplication* self;

};

class SMOKETESTLIB_EXPORT VirtualMethodTester {
public:
    VirtualMethodTester() {};

    virtual const char* name() const;
    virtual const char* getName() const; // alias for name
    virtual void setName(const char* newName);

    virtual void pureVirtualMethod() = 0;

private:
    const char* m_name;
};
