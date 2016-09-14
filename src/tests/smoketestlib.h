class QApplication {
public:
    QApplication();

    static QApplication* instance() { return self; }
private:
    static QApplication* self;
};
