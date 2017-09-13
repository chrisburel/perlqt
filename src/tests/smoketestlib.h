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

template <class T>
class HandlersTesterType<const T&> {
public:
    const T& get() const { return data; }
    void set(const T& newData) { data = newData; }

private:
    T data;
};

template <class T>
class HandlersTesterType<T*> {
public:
    ~HandlersTesterType() {
        if (data) delete data;
    }

    T* get() const { return data; }
    void set(T* newData) {
        if (data) delete data;

        if (newData) data = new T(*newData);
        else data = nullptr;
    }

private:
    T* data;
};

class SMOKETESTLIB_EXPORT HandlersTester
    : private HandlersTesterType<bool>
    , private HandlersTesterType<char>
    , private HandlersTesterType<unsigned char>
    , private HandlersTesterType<double>
    , private HandlersTesterType<float>
    , private HandlersTesterType<int>
    , private HandlersTesterType<int*>
    , private HandlersTesterType<const int*>
    , private HandlersTesterType<const int&>
    , private HandlersTesterType<unsigned int>
    , private HandlersTesterType<long>
    , private HandlersTesterType<unsigned long>
    , private HandlersTesterType<short>
    , private HandlersTesterType<unsigned short>
{
public:
#define MAKE_GETTER(type, uctype) \
    type get##uctype() const { return HandlersTesterType<type>::get(); } \
    void set##uctype(type newValue) { HandlersTesterType<type>::set(newValue); }


    MAKE_GETTER(bool, Bool);
    MAKE_GETTER(char, Char);
    MAKE_GETTER(unsigned char, UnsignedChar);
    MAKE_GETTER(double, Double);
    MAKE_GETTER(float, Float);
    MAKE_GETTER(int, Int);
    MAKE_GETTER(int*, IntStar);
    MAKE_GETTER(const int&, ConstIntRef);
    MAKE_GETTER(unsigned int, UnsignedInt);
    MAKE_GETTER(long, Long);
    MAKE_GETTER(unsigned long, UnsignedLong);
    MAKE_GETTER(short, Short);
    MAKE_GETTER(unsigned short, UnsignedShort);

    void setIntStarMultBy2Mutate(int* newValue) {
        if (newValue) *newValue *= 2;
        HandlersTesterType<int*>::set(newValue);
    }

    void setIntRefMultBy2Mutate(int& newValue) {
        newValue *= 2;
        HandlersTesterType<int>::set(newValue);
    }
};
