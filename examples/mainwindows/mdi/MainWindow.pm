package MainWindow;

use strict;
use warnings;
use blib;

use Qt;
use Qt::isa qw( Qt::QMainWindow );
use Qt::slots
    newFile => [''],
    openSlot => [''],
    save => [''],
    saveAs => [''],
    cut => [''],
    copy => [''],
    paste => [''],
    about => [''],
    updateMenus => [''],
    updateWindowMenu => [''],
    createMdiChild => [''],
    switchLayoutDirection => [''],
    setActiveSubWindow => ['QObject*'];

use MdiChild;

sub NEW {
    shift->SUPER::NEW(@_);
    my $mdiArea = Qt::QMdiArea();
    this->{mdiArea} = $mdiArea;
    this->setCentralWidget($mdiArea);
    this->connect($mdiArea, SIGNAL 'subWindowActivated(QMdiSubWindow *)',
                  this, SLOT 'updateMenus()');
    my $windowMapper = Qt::QSignalMapper(this);
    this->{windowMapper} = $windowMapper;
    this->connect($windowMapper, SIGNAL 'mapped(QObject*)',
                  this, SLOT 'setActiveSubWindow(QObject*)');

    createActions();
    createMenus();
    createToolBars();
    createStatusBar();
    updateMenus();

    readSettings();

    this->setWindowTitle("MDI");
}

sub closeEvent {
    my ( $event ) = @_;

    $DB::single=1;
    Qt::_internal::setDebug(0xffffff);
    this->{mdiArea}->closeAllSubWindows();
    Qt::_internal::setDebug(0);
    if (activeMdiChild()) {
        $event->ignore();
    } else {
        writeSettings();
        $event->accept();
    }
}

sub newFile {
    my $child = createMdiChild();
    $child->newFile();
    $child->show();
}

sub openSlot {
    my $fileName = Qt::QFileDialog::getOpenFileName(this);
    if ($fileName) {
        my $existing = findMdiChild($fileName);
        if ($existing) {
            this->{mdiArea}->setActiveSubWindow($existing);
            return;
        }

        my $child = createMdiChild();
        if ($child->loadFile($fileName)) {
            this->statusBar()->showMessage("File loaded", 2000);
            $child->show();
        } else {
            $child->close();
        }
        push @{this->{children}}, $child;
    }
}

sub save {
    if (activeMdiChild() && activeMdiChild()->save()) {
        this->statusBar()->showMessage("File saved", 2000);
    }
}

sub saveAs {
    if (activeMdiChild() && activeMdiChild()->saveAs()) {
        this->statusBar()->showMessage("File saved", 2000);
    }
}

sub cut {
    if (activeMdiChild()) {
        activeMdiChild()->cut();
    }
}

sub copy {
    if (activeMdiChild()) {
        activeMdiChild()->copy();
    }
}

sub paste {
    if (activeMdiChild()) {
        activeMdiChild()->paste();
    }
}

sub about {
   Qt::QMessageBox::about(this, "About MDI",
            "The <b>MDI</b> example demonstrates how to write multiple " .
            "document interface applications using Qt.");
}

sub updateMenus {
    my $hasMdiChild = (activeMdiChild() != 0);
    this->{saveAct}->setEnabled($hasMdiChild);
    this->{saveAsAct}->setEnabled($hasMdiChild);
    this->{pasteAct}->setEnabled($hasMdiChild);
    this->{closeAct}->setEnabled($hasMdiChild);
    this->{closeAllAct}->setEnabled($hasMdiChild);
    this->{tileAct}->setEnabled($hasMdiChild);
    this->{cascadeAct}->setEnabled($hasMdiChild);
    this->{nextAct}->setEnabled($hasMdiChild);
    this->{previousAct}->setEnabled($hasMdiChild);
    this->{separatorAct}->setVisible($hasMdiChild);

    my $hasSelection = (this->activeMdiChild() &&
                        this->activeMdiChild()->textCursor()->hasSelection());
    this->{cutAct}->setEnabled($hasSelection);
    this->{copyAct}->setEnabled($hasSelection);
}

sub updateWindowMenu {
    this->{windowMenu}->clear();
    this->{windowMenu}->addAction(this->{closeAct});
    this->{windowMenu}->addAction(this->{closeAllAct});
    this->{windowMenu}->addSeparator();
    this->{windowMenu}->addAction(this->{tileAct});
    this->{windowMenu}->addAction(this->{cascadeAct});
    this->{windowMenu}->addSeparator();
    this->{windowMenu}->addAction(this->{nextAct});
    this->{windowMenu}->addAction(this->{previousAct});
    this->{windowMenu}->addAction(this->{separatorAct});

    my @windows = @{this->{mdiArea}->subWindowList()};
    this->{separatorAct}->setVisible(scalar @windows);

    foreach my $i ( 0..$#windows ) {
        my $child = $windows[$i]->widget();

        my $text;
        if ($i < 9) {
            $text = sprintf "&%d %s", $i + 1,
                               $child->userFriendlyCurrentFile();
        } else {
            $text = sprintf "%s %s", $i + 1,
                              $child->userFriendlyCurrentFile();
        }
        my $action  = this->{windowMenu}->addAction($text);
        $action->setCheckable(1);
        $action->setChecked($child == activeMdiChild());
        this->connect($action, SIGNAL 'triggered()', this->{windowMapper}, SLOT 'map()');
        this->{windowMapper}->setMapping($action, $windows[$i]);
    }
}

sub createMdiChild {
    my $child = MdiChild();
    this->{mdiArea}->addSubWindow($child);

    this->connect($child, SIGNAL 'copyAvailable(bool)',
                  this->{cutAct}, SLOT 'setEnabled(bool)');
    this->connect($child, SIGNAL 'copyAvailable(bool)',
                  this->{copyAct}, SLOT 'setEnabled(bool)');

    return $child;
}

sub createActions {
    my $newAct = Qt::QAction(Qt::QIcon("images/new.png"), "&New", this);
    this->{newAct} = $newAct;
    $newAct->setShortcut(Qt::QKeySequence("Ctrl+N"));
    $newAct->setStatusTip("Create a new file");
    this->connect($newAct, SIGNAL 'triggered()', this, SLOT 'newFile()');

    my $openAct = Qt::QAction(Qt::QIcon("images/open.png"), "&Open...", this);
    this->{openAct} = $openAct;
    $openAct->setShortcut(Qt::QKeySequence("Ctrl+O"));
    $openAct->setStatusTip("Open an existing file");
    this->connect($openAct, SIGNAL 'triggered()', this, SLOT 'openSlot()');

    my $saveAct = Qt::QAction(Qt::QIcon("images/save.png"), "&Save", this);
    this->{saveAct} = $saveAct;
    $saveAct->setShortcut(Qt::QKeySequence("Ctrl+S"));
    $saveAct->setStatusTip("Save the document to disk");
    this->connect($saveAct, SIGNAL 'triggered()', this, SLOT 'save()');

    my $saveAsAct = Qt::QAction("Save &As...", this);
    this->{saveAsAct} = $saveAsAct;
    $saveAsAct->setStatusTip("Save the document under a new name");
    this->connect($saveAsAct, SIGNAL 'triggered()', this, SLOT 'saveAs()');

    my $exitAct = Qt::QAction("E&xit", this);
    this->{exitAct} = $exitAct;
    $exitAct->setShortcut(Qt::QKeySequence("Ctrl+Q"));
    $exitAct->setStatusTip("Exit the application");
    this->connect($exitAct, SIGNAL 'triggered()', Qt::qapp(), SLOT 'closeAllWindows()');

    my $cutAct = Qt::QAction(Qt::QIcon("images/cut.png"), "Cu&t", this);
    this->{cutAct} = $cutAct;
    $cutAct->setShortcut(Qt::QKeySequence("Ctrl+X"));
    $cutAct->setStatusTip("Cut the current selection's contents to the " .
                            "clipboard");
    this->connect($cutAct, SIGNAL 'triggered()', this, SLOT 'cut()');

    my $copyAct = Qt::QAction(Qt::QIcon("images/copy.png"), "&Copy", this);
    this->{copyAct} = $copyAct;
    $copyAct->setShortcut(Qt::QKeySequence("Ctrl+C"));
    $copyAct->setStatusTip("Copy the current selection's contents to the " .
                             "clipboard");
    this->connect($copyAct, SIGNAL 'triggered()', this, SLOT 'copy()');

    my $pasteAct = Qt::QAction(Qt::QIcon("images/paste.png"), "&Paste", this);
    this->{pasteAct} = $pasteAct;
    $pasteAct->setShortcut(Qt::QKeySequence("Ctrl+V"));
    $pasteAct->setStatusTip("Paste the clipboard's contents into the current " .
                              "selection");
    this->connect($pasteAct, SIGNAL 'triggered()', this, SLOT 'paste()');

    my $closeAct = Qt::QAction("Cl&ose", this);
    this->{closeAct} = $closeAct;
    $closeAct->setShortcut(Qt::QKeySequence("Ctrl+F4"));
    $closeAct->setStatusTip("Close the active window");
    this->connect($closeAct, SIGNAL 'triggered()',
            this->{mdiArea}, SLOT 'closeActiveSubWindow()');

    my $closeAllAct = Qt::QAction("Close &All", this);
    this->{closeAllAct} = $closeAllAct;
    $closeAllAct->setStatusTip("Close all the windows");
    this->connect($closeAllAct, SIGNAL 'triggered()',
            this->{mdiArea}, SLOT 'closeAllSubWindows()');

    my $tileAct = Qt::QAction("&Tile", this);
    this->{tileAct} = $tileAct;
    $tileAct->setStatusTip("Tile the windows");
    this->connect($tileAct, SIGNAL 'triggered()', this->{mdiArea}, SLOT 'tileSubWindows()');

    my $cascadeAct = Qt::QAction("&Cascade", this);
    this->{cascadeAct} = $cascadeAct;
    $cascadeAct->setStatusTip("Cascade the windows");
    this->connect($cascadeAct, SIGNAL 'triggered()', this->{mdiArea}, SLOT 'cascadeSubWindows()');

    my $nextAct = Qt::QAction("Ne&xt", this);
    this->{nextAct} = $nextAct;
    $nextAct->setStatusTip("Move the focus to the next window");
    this->connect($nextAct, SIGNAL 'triggered()',
            this->{mdiArea}, SLOT 'activateNextSubWindow()');

    my $previousAct = Qt::QAction("Pre&vious", this);
    this->{previousAct} = $previousAct;
    $previousAct->setStatusTip("Move the focus to the previous " .
                                 "window");
    this->connect($previousAct, SIGNAL 'triggered()',
            this->{mdiArea}, SLOT 'activatePreviousSubWindow()');

    my $separatorAct = Qt::QAction(this);
    this->{separatorAct} = $separatorAct;
    $separatorAct->setSeparator(1);

    my $aboutAct = Qt::QAction("&About", this);
    this->{aboutAct} = $aboutAct;
    $aboutAct->setStatusTip("Show the application's About box");
    this->connect($aboutAct, SIGNAL 'triggered()', this, SLOT 'about()');

    my $aboutQtAct = Qt::QAction("About &Qt", this);
    this->{aboutQtAct} = $aboutQtAct;
    $aboutQtAct->setStatusTip("Show the Qt library's About box");
    this->connect($aboutQtAct, SIGNAL 'triggered()', Qt::qapp(), SLOT 'aboutQt()');
}

sub createMenus {
    my $fileMenu = this->menuBar()->addMenu("&File");
    $fileMenu->addAction(this->{newAct});
    $fileMenu->addAction(this->{openAct});
    $fileMenu->addAction(this->{saveAct});
    $fileMenu->addAction(this->{saveAsAct});
    $fileMenu->addSeparator();
    my $action = $fileMenu->addAction("Switch layout direction");
    this->connect($action, SIGNAL 'triggered()', this, SLOT 'switchLayoutDirection()');
    $fileMenu->addAction(this->{exitAct});

    my $editMenu = this->menuBar()->addMenu("&Edit");
    $editMenu->addAction(this->{cutAct});
    $editMenu->addAction(this->{copyAct});
    $editMenu->addAction(this->{pasteAct});

    my $windowMenu = this->menuBar()->addMenu("&Window");
    this->{windowMenu} = $windowMenu;
    this->updateWindowMenu();
    this->connect($windowMenu, SIGNAL 'aboutToShow()', this, SLOT 'updateWindowMenu()');

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
    my $settings = Qt::QSettings("Trolltech", "MDI Example");
    my $pos = $settings->value("pos", Qt::QVariant(Qt::QPoint(200, 200)))->toPoint();
    my $size = $settings->value("size", Qt::QVariant(Qt::QSize(400, 400)))->toSize();
    this->resize($size);
    this->move($pos);
}

sub writeSettings {
    my $settings = Qt::QSettings("Trolltech", "MDI Example");
    $settings->setValue("pos", Qt::QVariant(this->pos()));
    $settings->setValue("size", Qt::QVariant(this->size()));
}

sub activeMdiChild {
    if (my $activeSubWindow = this->{mdiArea}->activeSubWindow()) {
        return CAST $activeSubWindow->widget(), ' MdiChild';
    }
    return 0;
}

sub findMdiChild {
    my( $fileName ) = @_;
    my $canonicalFilePath = Qt::QFileInfo($fileName)->canonicalFilePath();

    foreach my $window ( @{this->{mdiArea}->subWindowList()} ) {
        my $mdiChild = CAST $window->widget(), ' MdiChild';
        if ($mdiChild->currentFile() eq $canonicalFilePath) {
            return $window;
        }
    }
    return 0;
}

sub switchLayoutDirection {
    if (this->layoutDirection() == Qt::Qt::LeftToRight()) {
        Qt::qapp()->setLayoutDirection(Qt::Qt::RightToLeft());
    }
    else {
        Qt::qapp()->setLayoutDirection(Qt::Qt::LeftToRight());
    }
}

sub setActiveSubWindow {
    my ( $window ) = @_;
    if (!$window){
        return;
    }
    this->{mdiArea}->setActiveSubWindow($window);
}

1;
