class QApplication {
public:
    QApplication();
    virtual ~QApplication();

    static QApplication* instance() { return self; }
private:
    static QApplication* self;
};
