package MainWindow;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::MainWindow );
use Qt4::slots
    newFile => [],
    open => [],
    save => [],
    saveAs => [],
    about => [],
    documentWasModified => [];
use MainWindow;

sub textEdit() {
    return this->{textEdit};
}

sub curFile() {
    return this->{curFile};
}

sub isUntitled() {
    return this->{isUntitled};
}

sub fileMenu() {
    return this->{fileMenu};
}

sub editMenu() {
    return this->{editMenu};
}

sub helpMenu() {
    return this->{helpMenu};
}

sub fileToolBar() {
    return this->{fileToolBar};
}

sub editToolBar() {
    return this->{editToolBar};
}

sub newAct() {
    return this->{newAct};
}

sub openAct() {
    return this->{openAct};
}

sub saveAct() {
    return this->{saveAct};
}

sub saveAsAct() {
    return this->{saveAsAct};
}

sub closeAct() {
    return this->{closeAct};
}

sub exitAct() {
    return this->{exitAct};
}

sub cutAct() {
    return this->{cutAct};
}

sub copyAct() {
    return this->{copyAct};
}

sub pasteAct() {
    return this->{pasteAct};
}

sub aboutAct() {
    return this->{aboutAct};
}

sub aboutQtAct() {
    return this->{aboutQtAct};
}

sub NEW
{
    my ( $class, $fileName ) = @_;
    $class->SUPER::NEW();
    this->init();
    if ( $fileName ) {
        this->loadFile( $fileName );
    }
    else {
        this->setCurrentFile(undef);
    }
}

sub closeEvent
{
    my ($event) = @_;
    if (this->maybeSave()) {
        this->writeSettings();
        $event->accept();
    } else {
        $event->ignore();
    }
}

sub newFile
{
    my $other = MainWindow();
    $other->move(this->x() + 40, this->y() + 40);
    $other->show();
}

sub open
{
    my $fileName = Qt4::FileDialog::getOpenFileName(this);
    if ($fileName) {
        my $existing = findMainWindow($fileName);
        if ($existing) {
            $existing->show();
            $existing->raise();
            $existing->activateWindow();
            return;
        }

        if (this->isUntitled && this->textEdit->document()->isEmpty()
                && !this->isWindowModified()) {
            this->loadFile($fileName);
        } else {
            my $other = MainWindow($fileName);
            if ($other->isUntitled) {
                $other->setParent( undef );
                $other->DESTROY();
                return;
            }
            $other->move(this->x() + 40, this->y() + 40);
            $other->show();
        }
    }
}

sub save
{
    if (this->isUntitled) {
        return this->saveAs();
    } else {
        return this->saveFile(this->curFile);
    }
}

sub saveAs
{
    my $fileName = Qt4::FileDialog::getSaveFileName(this, this->tr('Save As'),
                                                    this->curFile);
    if (!$fileName) {
        return 0;
    }

    return this->saveFile($fileName);
}

sub about
{
   Qt4::MessageBox::about(this, this->tr('About SDI'),
            this->tr('The <b>SDI</b> example demonstrates how to write single ' .
               'document interface applications using Qt.'));
}

sub documentWasModified
{
    this->setWindowModified(1);
}

sub init
{
    this->setAttribute(Qt4::WA_DeleteOnClose());

    this->{isUntitled} = 1;

    this->{textEdit} = Qt4::TextEdit();
    this->setCentralWidget(this->textEdit);

    this->createActions();
    this->createMenus();
    this->createToolBars();
    this->createStatusBar();

    this->readSettings();

    this->connect(this->textEdit->document(), SIGNAL 'contentsChanged()',
            this, SLOT 'documentWasModified()');

    this->setUnifiedTitleAndToolBarOnMac(1);
}

sub createActions
{
    this->{newAct} = Qt4::Action(Qt4::Icon('images/new.png'), this->tr('&New'), this);
    this->newAct->setShortcuts(Qt4::KeySequence::New());
    this->newAct->setStatusTip(this->tr('Create a file'));
    this->connect(this->newAct, SIGNAL 'triggered()', this, SLOT 'newFile()');

    this->{openAct} = Qt4::Action(Qt4::Icon('images/open.png'), this->tr('&Open...'), this);
    this->openAct->setShortcuts(Qt4::KeySequence::Open());
    this->openAct->setStatusTip(this->tr('Open an existing file'));
    this->connect(this->openAct, SIGNAL 'triggered()', this, SLOT 'open()');

    this->{saveAct} = Qt4::Action(Qt4::Icon('images/save.png'), this->tr('&Save'), this);
    this->saveAct->setShortcuts(Qt4::KeySequence::Save());
    this->saveAct->setStatusTip(this->tr('Save the document to disk'));
    this->connect(this->saveAct, SIGNAL 'triggered()', this, SLOT 'save()');

    this->{saveAsAct} = Qt4::Action(this->tr('Save &As...'), this);
    this->saveAsAct->setShortcut(Qt4::KeySequence('Ctrl+A'));
    this->saveAsAct->setStatusTip(this->tr('Save the document under a name'));
    this->connect(this->saveAsAct, SIGNAL 'triggered()', this, SLOT 'saveAs()');

    this->{closeAct} = Qt4::Action(this->tr('&Close'), this);
    this->closeAct->setShortcut(Qt4::KeySequence(this->tr('Ctrl+W')));
    this->closeAct->setStatusTip(this->tr('Close this window'));
    this->connect(this->closeAct, SIGNAL 'triggered()', this, SLOT 'close()');

    this->{exitAct} = Qt4::Action(this->tr('E&xit'), this);
    this->exitAct->setShortcut(Qt4::KeySequence(this->tr('Ctrl+Q')));
    this->exitAct->setStatusTip(this->tr('Exit the application'));
    this->connect(this->exitAct, SIGNAL 'triggered()', qApp, SLOT 'closeAllWindows()');

    this->{cutAct} = Qt4::Action(Qt4::Icon('images/cut.png'), this->tr('Cu&t'), this);
    this->cutAct->setShortcuts(Qt4::KeySequence::Cut());
    this->cutAct->setStatusTip(this->tr('Cut the current selection\'s contents to the ' .
                            'clipboard'));
    this->connect(this->cutAct, SIGNAL 'triggered()', textEdit, SLOT 'cut()');

    this->{copyAct} = Qt4::Action(Qt4::Icon('images/copy.png'), this->tr('&Copy'), this);
    this->copyAct->setShortcuts(Qt4::KeySequence::Copy());
    this->copyAct->setStatusTip(this->tr('Copy the current selection\'s contents to the ' .
                             'clipboard'));
    this->connect(this->copyAct, SIGNAL 'triggered()', textEdit, SLOT 'copy()');

    this->{pasteAct} = Qt4::Action(Qt4::Icon('images/paste.png'), this->tr('&Paste'), this);
    this->pasteAct->setShortcuts(Qt4::KeySequence::Paste());
    this->pasteAct->setStatusTip(this->tr('Paste the clipboard\'s contents into the current ' .
                              'selection'));
    this->connect(this->pasteAct, SIGNAL 'triggered()', textEdit, SLOT 'paste()');

    this->{aboutAct} = Qt4::Action(this->tr('&About'), this);
    this->aboutAct->setStatusTip(this->tr('Show the application\'s About box'));
    this->connect(this->aboutAct, SIGNAL 'triggered()', this, SLOT 'about()');

    this->{aboutQtAct} = Qt4::Action(this->tr('About &Qt'), this);
    this->aboutQtAct->setStatusTip(this->tr('Show the Qt4 library\'s About box'));
    this->connect(this->aboutQtAct, SIGNAL 'triggered()', qApp, SLOT 'aboutQt()');


    this->cutAct->setEnabled(0);
    this->copyAct->setEnabled(0);
    this->connect(textEdit, SIGNAL 'copyAvailable(bool)',
            this->cutAct, SLOT 'setEnabled(bool)');
    this->connect(textEdit, SIGNAL 'copyAvailable(bool)',
            this->copyAct, SLOT 'setEnabled(bool)');
}

# [implicit tr context]
sub createMenus
{
    this->{fileMenu} = this->menuBar()->addMenu(this->tr('&File'));
# [implicit tr context]
    this->fileMenu->addAction(this->newAct);
    this->fileMenu->addAction(this->openAct);
    this->fileMenu->addAction(this->saveAct);
    this->fileMenu->addAction(this->saveAsAct);
    this->fileMenu->addSeparator();
    this->fileMenu->addAction(this->closeAct);
    this->fileMenu->addAction(this->exitAct);

    this->{editMenu} = this->menuBar()->addMenu(this->tr('&Edit'));
    this->editMenu->addAction(this->cutAct);
    this->editMenu->addAction(this->copyAct);
    this->editMenu->addAction(this->pasteAct);

    this->menuBar()->addSeparator();

    this->{helpMenu} = this->menuBar()->addMenu(this->tr('&Help'));
    this->helpMenu->addAction(this->aboutAct);
    this->helpMenu->addAction(this->aboutQtAct);
}

sub createToolBars
{
# [0]
    this->{fileToolBar} = this->addToolBar(this->tr('File'));
    this->fileToolBar->addAction(this->newAct);
    this->fileToolBar->addAction(this->openAct);
# [0]
    this->fileToolBar->addAction(this->saveAct);

    this->{editToolBar} = this->addToolBar(this->tr('Edit'));
    this->editToolBar->addAction(this->cutAct);
    this->editToolBar->addAction(this->copyAct);
    this->editToolBar->addAction(this->pasteAct);
}

sub createStatusBar
{
    this->statusBar()->showMessage(this->tr('Ready'));
}

sub readSettings
{
    my $settings = Qt4::Settings('Trolltech', 'SDI Example');
    my $pos = $settings->value('pos', Qt4::Variant(Qt4::Point(200, 200)))->toPoint();
    my $size = $settings->value('size', Qt4::Variant(Qt4::Size(400, 400)))->toSize();
    this->move($pos);
    this->resize($size);
}

sub writeSettings
{
    my $settings = Qt4::Settings('Trolltech', 'SDI Example');
    $settings->setValue('pos', Qt4::Variant(this->pos()));
    $settings->setValue('size', Qt4::Variant(this->size()));
}

sub maybeSave
{
    if (this->textEdit->document()->isModified()) {
        my $ret = Qt4::MessageBox::warning(this, this->tr('SDI'),
                     this->tr("The document has been modified.\n" .
                        'Do you want to save your changes?'),
                     Qt4::MessageBox::Save() | Qt4::MessageBox::Discard()
		     | Qt4::MessageBox::Cancel());
        if ($ret == Qt4::MessageBox::Save()) {
            return this->save();
        }
        elsif ($ret == Qt4::MessageBox::Cancel()) {
            return 0;
        }
    }
    return 1;
}

sub loadFile
{
    my ($fileName) = @_;

    my $file = Qt4::File($fileName);
    if (!$file->open(Qt4::File::ReadOnly() | Qt4::File::Text())) {
        Qt4::MessageBox::warning(this, this->tr('SDI'),
                     sprintf this->tr('Cannot read file %s:\n%s.'),
                             $fileName,
                             $file->errorString());
        return;
    }

    my $in = Qt4::TextStream($file);
    Qt4::Application::setOverrideCursor(Qt4::Cursor(Qt4::WaitCursor()));
    this->textEdit->setPlainText($in->readAll());
    Qt4::Application::restoreOverrideCursor();
    $file->close();

    this->setCurrentFile($fileName);
    this->statusBar()->showMessage(this->tr('File loaded'), 2000);
}

sub saveFile
{
    my ($fileName) = @_;
    my $file = Qt4::File($fileName);
    if (!$file->open(Qt4::File::WriteOnly() | Qt4::File::Text())) {
        Qt4::MessageBox::warning(this, this->tr('SDI'),
                     sprintf this->tr('Cannot write file %s:\n%s.'),
                             $fileName,
                             $file->errorString());
        return 0;
    }

    my $out = Qt4::TextStream($file);
    Qt4::Application::setOverrideCursor(Qt4::Cursor(Qt4::WaitCursor()));
    no warnings qw(void); # For bitshift warning
    $out << Qt4::String(this->textEdit->toPlainText());
    use warnings;
    Qt4::Application::restoreOverrideCursor();
    $file->close();

    this->setCurrentFile($fileName);
    this->statusBar()->showMessage(this->tr('File saved'), 2000);
    return 1;
}

my $sequenceNumber = 1;
sub setCurrentFile
{
    my ($fileName) = @_;

    this->{isUntitled} = $fileName ? 0 : 1;;
    if (this->isUntitled) {
        this->{curFile} = sprintf this->tr('document%d.txt'), $sequenceNumber++;
    } else {
        this->{curFile} = Qt4::FileInfo($fileName)->canonicalFilePath();
    }

    this->textEdit->document()->setModified(0);
    this->setWindowModified(0);

    this->setWindowTitle(sprintf this->tr('%s[*] - %s'), this->strippedName(this->curFile),
                                       this->tr('SDI'));
}

sub strippedName
{
    my ($fullFileName) = @_;
    return Qt4::FileInfo($fullFileName)->fileName();
}

sub findMainWindow
{
    my ($fileName) = @_;
    my $canonicalFilePath = Qt4::FileInfo($fileName)->canonicalFilePath();

    foreach my $widget ( @{qApp->topLevelWidgets()} ) {
        next unless ref $widget;
        my $mainWin = $widget->qobject_cast( 'Qt4::MainWindow' );
        if ($mainWin && $mainWin->curFile eq $canonicalFilePath) {
            return $mainWin;
        }
    }
    return 0;
}

1;
