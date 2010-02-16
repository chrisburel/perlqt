package MainWindow;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::MainWindow );
use Qt4::slots
    openFile => [];
use DomModel;

sub model() {
    return this->{model};
}

sub setModel($) {
    return this->{model} = shift;
}

sub fileMenu() {
    return this->{fileMenu};
}

sub setFileMenu($) {
    return this->{fileMenu} = shift;
}

sub xmlPath() {
    return this->{xmlPath};
}

sub setXmlPath($) {
    return this->{xmlPath} = shift;
}

sub view() {
    return this->{view};
}

sub setView($) {
    return this->{view} = shift;
}

sub NEW
{
    my ( $class ) = @_;
    $class->SUPER::NEW();
    this->setFileMenu( this->menuBar()->addMenu(this->tr('&File')) );
    this->fileMenu->addAction(this->tr('&Open...'), this, SLOT 'openFile()',
                        Qt4::KeySequence(this->tr('Ctrl+O')));
    this->fileMenu->addAction(this->tr('E&xit'), this, SLOT 'close()',
                        Qt4::KeySequence(this->tr('Ctrl+Q')));

    this->setModel( DomModel(Qt4::DomDocument(), this) );
    this->setView( Qt4::TreeView(this) );
    this->view->setModel(this->model);

    this->setCentralWidget(this->view);
    this->setWindowTitle(this->tr('Simple DOM Model'));
}

sub openFile
{
    my $filePath = Qt4::FileDialog::getOpenFileName(this, this->tr('Open File'),
        this->xmlPath, this->tr('XML files (*.xml);;HTML files (*.html);;' .
                    'SVG files (*.svg);;User Interface files (*.ui)'));

    if ($filePath) {
        my $file = Qt4::File($filePath);
        if ($file->open(Qt4::IODevice::ReadOnly())) {
            my $document = Qt4::DomDocument();
            if ($document->setContent($file)) {
                my $newModel = DomModel($document, this);
                this->view->setModel($newModel);
                this->setModel( $newModel );
                this->setXmlPath( $filePath );
            }
            $file->close();
        }
    }
}

1;
