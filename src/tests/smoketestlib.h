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

template <class T>
class HandlersTesterType {
public:
    T get() const { return data; }
    void set(const T& newData) { data = newData; }
private:
    T data;
};

class SMOKETESTLIB_EXPORT HandlersTester
    : private HandlersTesterType<char>
    , private HandlersTesterType<double>
    , private HandlersTesterType<float>
    , private HandlersTesterType<int>
{
public:
#define MAKE_GETTER(type, uctype) \
    type get##uctype() const { return HandlersTesterType<type>::get(); } \
    void set##uctype(type newValue) { HandlersTesterType<type>::set(newValue); }

    MAKE_GETTER(char, Char);
    MAKE_GETTER(double, Double);
    MAKE_GETTER(float, Float);
    MAKE_GETTER(int, Int);
};
