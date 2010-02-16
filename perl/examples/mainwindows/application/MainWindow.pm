package MainWindow;

use strict;
use blib;

use File::Basename;

use Qt4;
use Qt4::isa qw( Qt4::MainWindow );
use Qt4::slots
                newFile => [],
                openFile => [],
                save => [],
                saveAs => [],
                about => [],
                documentWasModified => [];

sub NEW {
    shift->SUPER::NEW(@_);

    my $textEdit = Qt4::TextEdit();
    this->setCentralWidget($textEdit);
    this->{textEdit} = $textEdit;

    createActions();
    createMenus();
    createToolBars();
    createStatusBar();

    readSettings();

    this->connect($textEdit->document(), SIGNAL 'contentsChanged()',
                  this, SLOT 'documentWasModified()');

    this->setCurrentFile("");
}

sub closeEvent {
    my ($event) = @_;
    if (maybeSave()) {
        writeSettings();
        $event->accept();
    } else {
        $event->ignore();
    }
}

sub newFile {
    if (maybeSave()) {
        this->{textEdit}->clear();
        setCurrentFile("");
    }
}

sub openFile {
    if (maybeSave()) {
        my $fileName = Qt4::FileDialog::getOpenFileName(this);
        if ($fileName) {
            loadFile($fileName);
        }
    }
}

sub save {
    if (!defined this->{curFile} || !this->{curFile}) {
        return saveAs();
    } else {
        return saveFile(this->{curFile});
    }
}

sub saveAs {
    my $fileName = Qt4::FileDialog::getSaveFileName(this);
    if (!defined $fileName){
        return 0;
    }

    return saveFile($fileName);
}

sub about {
    Qt4::MessageBox::about(this, "About Application",
            "The <b>Application</b> example demonstrates how to " .
               "write modern GUI applications using Qt, with a menu bar, " .
               "toolbars, and a status bar.");
}

sub documentWasModified {
    this->setWindowModified(this->{textEdit}->document()->isModified());
}

sub createActions {
    my $textEdit = this->{textEdit};
    my $newAct =  Qt4::Action(Qt4::Icon("images/new.png"), "&New", this);
    $newAct->setShortcut(Qt4::KeySequence("Ctrl+N"));
    $newAct->setStatusTip("Create a new file");
    this->connect($newAct, SIGNAL 'triggered()', this, SLOT 'newFile()');
    this->{newAct} = $newAct;

    my $openAct = Qt4::Action(Qt4::Icon("images/open.png"), "&Open...", this);
    $openAct->setShortcut(Qt4::KeySequence("Ctrl+O"));
    $openAct->setStatusTip("Open an existing file");
    this->connect($openAct, SIGNAL 'triggered()', this, SLOT 'openFile()');
    this->{openAct} = $openAct;

    my $saveAct = Qt4::Action(Qt4::Icon("images/save.png"), "&Save", this);
    $saveAct->setShortcut(Qt4::KeySequence("Ctrl+S"));
    $saveAct->setStatusTip("Save the document to disk");
    this->connect($saveAct, SIGNAL 'triggered()', this, SLOT 'save()');
    this->{saveAct} = $saveAct;

    my $saveAsAct = Qt4::Action("Save &As...", this);
    $saveAsAct->setStatusTip("Save the document under a new name");
    this->connect($saveAsAct, SIGNAL 'triggered()', this, SLOT 'saveAs()');
    this->{saveAsAct} = $saveAsAct;

    my $exitAct = Qt4::Action("E&xit", this);
    $exitAct->setShortcut(Qt4::KeySequence("Ctrl+Q"));
    $exitAct->setStatusTip("Exit the application");
    this->connect($exitAct, SIGNAL 'triggered()', this, SLOT 'close()');
    this->{exitAct} = $exitAct;

    my $cutAct = Qt4::Action(Qt4::Icon("images/cut.png"), "Cu&t", this);
    $cutAct->setShortcut(Qt4::KeySequence("Ctrl+X"));
    $cutAct->setStatusTip("Cut the current selection's contents to the " .
                            "clipboard");
    this->connect($cutAct, SIGNAL 'triggered()', $textEdit, SLOT 'cut()');
    this->{cutAct} = $cutAct;

    my $copyAct = Qt4::Action(Qt4::Icon("images/copy.png"), "&Copy", this);
    $copyAct->setShortcut(Qt4::KeySequence("Ctrl+C"));
    $copyAct->setStatusTip("Copy the current selection's contents to the " .
                             "clipboard");
    this->connect($copyAct, SIGNAL 'triggered()', $textEdit, SLOT 'copy()');
    this->{copyAct} = $copyAct;

    my $pasteAct = Qt4::Action(Qt4::Icon("images/paste.png"), "&Paste", this);
    $pasteAct->setShortcut(Qt4::KeySequence("Ctrl+V"));
    $pasteAct->setStatusTip("Paste the clipboard's contents into the current " .
                              "selection");
    this->connect($pasteAct, SIGNAL 'triggered()', $textEdit, SLOT 'paste()');
    this->{pasteAct} = $pasteAct;

    my $aboutAct = Qt4::Action("&About", this);
    $aboutAct->setStatusTip("Show the application's About box");
    this->connect($aboutAct, SIGNAL 'triggered()', this, SLOT 'about()');
    this->{aboutAct} = $aboutAct;

    my $aboutQtAct = Qt4::Action("About &Qt", this);
    $aboutQtAct->setStatusTip("Show the Qt4 library's About box");
    this->connect($aboutQtAct, SIGNAL 'triggered()', Qt4::qApp(), SLOT 'aboutQt()');
    this->{aboutQtAct} = $aboutQtAct;

    $cutAct->setEnabled(0);
    $copyAct->setEnabled(0);
    this->connect($textEdit, SIGNAL 'copyAvailable(bool)',
                  $cutAct, SLOT 'setEnabled(bool)');
    this->connect($textEdit, SIGNAL 'copyAvailable(bool)',
                  $copyAct, SLOT 'setEnabled(bool)');
}

sub createMenus {
    my $fileMenu = this->menuBar()->addMenu("&File");
    $fileMenu->addAction(this->{newAct});
    $fileMenu->addAction(this->{openAct});
    $fileMenu->addAction(this->{saveAct});
    $fileMenu->addAction(this->{saveAsAct});
    $fileMenu->addSeparator();
    $fileMenu->addAction(this->{exitAct});

    my $editMenu = this->menuBar()->addMenu("&Edit");
    $editMenu->addAction(this->{cutAct});
    $editMenu->addAction(this->{copyAct});
    $editMenu->addAction(this->{pasteAct});

    this->menuBar()->addSeparator();

    my $helpMenu = this->menuBar()->addMenu("&Help");
    $helpMenu->addAction(this->{aboutAct});
    $helpMenu->addAction(this->{aboutQtAct});
}

sub createToolBars {
    my $fileToolBar = this->addToolBar("File");
    $fileToolBar->addAction(this->{newAct});
    $fileToolBar->addAction(this->{openAct});
    $fileToolBar->addAction(this->{saveAct});

    my $editToolBar = this->addToolBar("Edit");
    $editToolBar->addAction(this->{cutAct});
    $editToolBar->addAction(this->{copyAct});
    $editToolBar->addAction(this->{pasteAct});
}

sub createStatusBar {
    this->statusBar()->showMessage("Ready");
}

sub readSettings {
    my $settings = Qt4::Settings("Trolltech", "Application Example");
    my $pos = $settings->value("pos", Qt4::Variant(Qt4::Point(200, 200)))->toPoint();
    my $size = $settings->value("size", Qt4::Variant(Qt4::Size(400, 400)))->toSize();
    this->resize($size);
    this->move($pos);
}

sub writeSettings {
    my $settings = Qt4::Settings("Trolltech", "Application Example");
    $settings->setValue("pos", Qt4::Variant(this->pos()));
    $settings->setValue("size", Qt4::Variant(this->size()));
}

sub maybeSave {
    if (this->{textEdit}->document()->isModified()) {
        my $ret = Qt4::MessageBox::warning(this, "Application",
                        "The document has been modified.\n" .
                        "Do you want to save your changes?",
                        CAST Qt4::MessageBox::Save() | Qt4::MessageBox::Discard() | Qt4::MessageBox::Cancel(), 'QMessageBox::StandardButtons'); 
        if ($ret == Qt4::MessageBox::Save()) {
            return save();
        }
        elsif ($ret == Qt4::MessageBox::Cancel()) {
            return 0;
        }
    }
    return 1;
}

sub loadFile {
    my ( $fileName ) = @_;
    if(!(open( FH, "< $fileName"))) {
        Qt4::MessageBox::warning(this, "Application",
                                 sprintf("Cannot read file %s:\n%s.",
                                 $fileName,
                                 $!));
        return 0;
    }

    Qt4::Application::setOverrideCursor(Qt4::Cursor(Qt4::WaitCursor()));
    this->{textEdit}->setPlainText(join "\n", <FH> );
    Qt4::Application::restoreOverrideCursor();
    close FH;

    setCurrentFile($fileName);
    this->statusBar()->showMessage("File loaded", 2000);
}

sub saveFile {
    my ($fileName) = @_;
    if(!(open( FH, "> $fileName"))) {
        Qt4::MessageBox::warning(this, "Application",
                                 sprintf("Cannot write file %s:\n%s.",
                                 $fileName,
                                 $!));
        return 0;
    }

    Qt4::Application::setOverrideCursor(Qt4::Cursor(Qt4::WaitCursor()));
    print FH this->{textEdit}->toPlainText();
    Qt4::Application::restoreOverrideCursor();
    close FH;

    setCurrentFile($fileName);
    this->statusBar()->showMessage("File saved", 2000);
    return 1;
}

sub setCurrentFile {
    my ( $fileName ) = @_;
    this->{curFile} = $fileName;
    this->{textEdit}->document()->setModified(0);
    this->setWindowModified(0);

    my $shownName;
    if (!defined this->{curFile} || !(this->{curFile})) {
        $shownName = "untitled.txt";
    }
    else {
        $shownName = strippedName(this->{curFile});
    }

    this->setWindowTitle(sprintf("%s\[*] - %s", $shownName, "Application"));
}

sub strippedName {
    my ( $fullFileName ) = @_;
    return basename( $fullFileName );
}

1;
