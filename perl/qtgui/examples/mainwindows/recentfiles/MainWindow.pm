package MainWindow;

use strict;
use warnings;
use Qt4;
use List::Util qw(min);

use Qt4::isa qw( Qt4::MainWindow );
use Qt4::slots
    newFile => [],
    open => [],
    save => [],
    saveAs => [],
    openRecentFile => [],
    about => [];

sub curFile() {
    return this->{curFile};
}

sub textEdit() {
    return this->{textEdit};
}

sub fileMenu() {
    return this->{fileMenu};
}

sub recentFilesMenu() {
    return this->{recentFilesMenu};
}

sub helpMenu() {
    return this->{helpMenu};
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

sub exitAct() {
    return this->{exitAct};
}

sub aboutAct() {
    return this->{aboutAct};
}

sub aboutQtAct() {
    return this->{aboutQtAct};
}

sub separatorAct() {
    return this->{separatorAct};
}

use constant {
    MaxRecentFiles => 5
};

sub recentFileActs {
    return this->{recentFileActs};
}

sub NEW {
    my ( $class ) = @_;
    $class->SUPER::NEW();
    this->setAttribute(Qt4::WA_DeleteOnClose());

    this->{recentFileActs} = [];
    this->{textEdit} = Qt4::TextEdit();
    this->setCentralWidget(this->textEdit);

    this->createActions();
    this->createMenus();
    this->statusBar();

    this->setWindowTitle(this->tr('Recent Files'));
    this->resize(400, 300);
}

sub newFile()
{
    my $other = MainWindow();
    $other->show();
}

sub open()
{
    my $fileName = Qt4::FileDialog::getOpenFileName(this);
    if ($fileName) {
        this->loadFile($fileName);
    }
}

sub save()
{
    if (!this->curFile) {
        this->saveAs();
    }
    else {
        this->saveFile(this->curFile);
    }
}

sub saveAs()
{
    my $fileName = Qt4::FileDialog::getSaveFileName(this);
    if (!$fileName) {
        return;
    }

    this->saveFile($fileName);
}

sub openRecentFile()
{
    my $action = this->sender();
    if ($action) {
        this->loadFile($action->data()->toString());
    }
}

sub about()
{
   Qt4::MessageBox::about(this, this->tr('About Recent Files'),
            this->tr('The <b>Recent Files</b> example demonstrates how to provide a ' .
               'recently used file menu in a Qt application.'));
}

sub createActions()
{
    my $newAct = this->{newAct} = Qt4::Action(this->tr('&New'), this);
    $newAct->setShortcuts(Qt4::KeySequence::New());
    $newAct->setStatusTip(this->tr('Create a file'));
    this->connect($newAct, SIGNAL 'triggered()', this, SLOT 'newFile()');

    my $openAct = this->{openAct} = Qt4::Action(this->tr('&Open...'), this);
    $openAct->setShortcuts(Qt4::KeySequence::Open());
    $openAct->setStatusTip(this->tr('Open an existing file'));
    this->connect($openAct, SIGNAL 'triggered()', this, SLOT 'open()');

    my $saveAct = this->{saveAct} = Qt4::Action(this->tr('&Save'), this);
    $saveAct->setShortcuts(Qt4::KeySequence::Save());
    $saveAct->setStatusTip(this->tr('Save the document to disk'));
    this->connect($saveAct, SIGNAL 'triggered()', this, SLOT 'save()');

    my $saveAsAct = this->{saveAsAct} = Qt4::Action(this->tr('Save &As...'), this);
    $saveAsAct->setShortcut(Qt4::KeySequence(this->tr('Ctrl+A')));
    $saveAsAct->setStatusTip(this->tr('Save the document under a name'));
    this->connect($saveAsAct, SIGNAL 'triggered()', this, SLOT 'saveAs()');

    foreach my $i (0..MaxRecentFiles-1) {
        this->recentFileActs->[$i] = Qt4::Action(this);
        this->recentFileActs->[$i]->setVisible(0);
        this->connect(this->recentFileActs->[$i], SIGNAL 'triggered()',
                this, SLOT 'openRecentFile()');
    }

    my $exitAct = this->{exitAct} = Qt4::Action(this->tr('E&xit'), this);
    $exitAct->setShortcut(Qt4::KeySequence(this->tr('Ctrl+Q')));
    $exitAct->setStatusTip(this->tr('Exit the application'));
    this->connect($exitAct, SIGNAL 'triggered()', qApp, SLOT 'closeAllWindows()');

    my $aboutAct = this->{aboutAct} = Qt4::Action(this->tr('&About'), this);
    $aboutAct->setStatusTip(this->tr('Show the application\'s About box'));
    this->connect($aboutAct, SIGNAL 'triggered()', this, SLOT 'about()');

    my $aboutQtAct = this->{aboutQtAct} = Qt4::Action(this->tr('About &Qt'), this);
    $aboutQtAct->setStatusTip(this->tr('Show the Qt4 library\'s About box'));
    this->connect($aboutQtAct, SIGNAL 'triggered()', qApp, SLOT 'aboutQt()');
}

sub createMenus()
{
    my $fileMenu = this->{fileMenu} = this->menuBar()->addMenu(this->tr('&File'));
    $fileMenu->addAction(this->newAct);
    $fileMenu->addAction(this->openAct);
    $fileMenu->addAction(this->saveAct);
    $fileMenu->addAction(this->saveAsAct);
    my $separatorAct = this->{separatorAct} = $fileMenu->addSeparator();
    foreach my $i (0..MaxRecentFiles-1) {
        $fileMenu->addAction(this->recentFileActs->[$i]);
    }
    $fileMenu->addSeparator();
    $fileMenu->addAction(this->exitAct);
    this->updateRecentFileActions();

    this->menuBar()->addSeparator();

    my $helpMenu = this->{helpMenu} = this->menuBar()->addMenu(this->tr('&Help'));
    $helpMenu->addAction(this->aboutAct);
    $helpMenu->addAction(this->aboutQtAct);
}

sub loadFile
{
    my ($fileName) = @_;
    my $file = Qt4::File($fileName);
    if (!$file->open(Qt4::File::ReadOnly() | Qt4::File::Text())) {
        Qt4::MessageBox::warning(this, this->tr('Recent Files'),
                     sprintf this->tr("Cannot read file %s:\n%s."),
                             $fileName,
                             $file->errorString());
        return;
    }

    my $in = Qt4::TextStream($file);
    Qt4::Application::setOverrideCursor(Qt4::Cursor(Qt4::WaitCursor()));
    this->textEdit->setPlainText($in->readAll());
    Qt4::Application::restoreOverrideCursor();

    this->setCurrentFile($fileName);
    this->statusBar()->showMessage(this->tr('File loaded'), 2000);
}

sub saveFile
{
    my ($fileName) = @_;
    my $file = Qt4::File($fileName);
    if (!$file->open(Qt4::File::WriteOnly() | Qt4::File::Text())) {
        Qt4::MessageBox::warning(this, this->tr('Recent Files'),
                     sprintf this->tr("Cannot write file %s:\n%s."),
                             $fileName,
                             $file->errorString());
        return;
    }

    my $out = Qt4::TextStream($file);
    Qt4::Application::setOverrideCursor(Qt4::Cursor(Qt4::WaitCursor()));
    no warnings qw(void); # For bitshift warning
    $out << this->textEdit->toPlainText();
    use warnings;
    Qt4::Application::restoreOverrideCursor();

    this->setCurrentFile($fileName);
    this->statusBar()->showMessage(this->tr('File saved'), 2000);
}

sub setCurrentFile
{
    my ($fileName) = @_;
    this->{curFile} = $fileName;
    if (!this->curFile) {
        this->setWindowTitle(this->tr('Recent Files'));
    }
    else {
        this->setWindowTitle(sprintf this->tr('%s - %s'), this->strippedName(this->curFile),
                                     this->tr('Recent Files'));
    }

    my $settings = Qt4::Settings('Trolltech', 'Recent Files Example');
    my $files = $settings->value('recentFileList')->toStringList();
    $files = [grep{ $_ ne $fileName} @{$files}];
    unshift @{$files}, $fileName;
    while (scalar @{$files} > MaxRecentFiles) {
        pop @{$files};
    }

    $settings->setValue('recentFileList', Qt4::Variant($files));

    foreach my $widget (@{Qt4::Application::topLevelWidgets()}) {
        my $mainWin = $widget->qobject_cast('Qt4::MainWindow');
        if ($mainWin) {
            $mainWin->updateRecentFileActions();
        }
    }
}

sub updateRecentFileActions()
{
    my $settings = Qt4::Settings('Trolltech', 'Recent Files Example');
    my $files = $settings->value('recentFileList')->toStringList();

    my $numRecentFiles = min(scalar @{$files}, MaxRecentFiles);

    foreach my $i (0..$numRecentFiles-1) {
        my $text = $i + 1 . ' ' . this->strippedName($files->[$i]);
        this->recentFileActs->[$i]->setText($text);
        this->recentFileActs->[$i]->setData(Qt4::Variant(Qt4::String($files->[$i])));
        this->recentFileActs->[$i]->setVisible(1);
    }
    foreach my $j ($numRecentFiles..MaxRecentFiles-1) {
        this->recentFileActs->[$j]->setVisible(0);
    }

    this->separatorAct->setVisible($numRecentFiles > 0);
}

sub strippedName
{
    my ($fullFileName) = @_;
    return Qt4::FileInfo($fullFileName)->fileName();
}

1;
