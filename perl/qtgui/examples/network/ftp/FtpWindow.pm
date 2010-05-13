package FtpWindow;

use strict;
use warnings;
use Qt4;
use Qt4::isa qw( Qt4::Dialog );
#[0]
use Qt4::slots
    connectOrDisconnect => [],
    downloadFile => [],
    cancelDownload => [],

    ftpCommandFinished => ['int', 'bool'],
    addToList => ['const QUrlInfo &'],
    processItem => ['QTreeWidgetItem *', 'int'],
    cdToParent => [],
    updateDataTransferProgress => ['qint64', 'qint64'],
    enableDownloadButton => [];
#[0]

sub ftpServerLabel() {
    return this->{ftpServerLabel};
}

sub ftpServerLineEdit() {
    return this->{ftpServerLineEdit};
}

sub statusLabel() {
    return this->{statusLabel};
}

sub fileList() {
    return this->{fileList};
}

sub cdToParentButton() {
    return this->{cdToParentButton};
}

sub connectButton() {
    return this->{connectButton};
}

sub downloadButton() {
    return this->{downloadButton};
}

sub quitButton() {
    return this->{quitButton};
}

sub buttonBox() {
    return this->{buttonBox};
}

sub progressDialog() {
    return this->{progressDialog};
}

sub isDirectory() {
    return this->{isDirectory};
}

sub currentPath() {
    return this->{currentPath};
}

sub ftp() {
    return this->{ftp};
}

sub file() {
    return this->{file};
}

sub NEW
{
    my ($class, $parent) = @_;
    $class->SUPER::NEW($parent);
    this->{ftp} = 0;
    this->{isDirectory} = {};
    this->{ftpServerLabel} = Qt4::Label(this->tr('Ftp &server:'));
    this->{ftpServerLineEdit} = Qt4::LineEdit('ftp.trolltech.com');
    this->ftpServerLabel->setBuddy(this->ftpServerLineEdit);

    this->{statusLabel} = Qt4::Label(this->tr('Please enter the name of an FTP server.'));

    this->{fileList} = Qt4::TreeWidget();
    this->fileList->setEnabled(0);
    this->fileList->setRootIsDecorated(0);
    this->fileList->setHeaderLabels( [this->tr('Name'), this->tr('Size'), this->tr('Owner'), this->tr('Group'), this->tr('Time')] );
    this->fileList->header()->setStretchLastSection(0);

    this->{connectButton} = Qt4::PushButton(this->tr('Connect'));
    this->connectButton->setDefault(1);
    
    this->{cdToParentButton} = Qt4::PushButton();
    this->cdToParentButton->setIcon(Qt4::Icon(Qt4::Pixmap('images/cdtoparent.png')));
    this->cdToParentButton->setEnabled(0);

    this->{downloadButton} = Qt4::PushButton(this->tr('Download'));
    this->downloadButton->setEnabled(0);

    this->{quitButton} = Qt4::PushButton(this->tr('Quit'));

    this->{buttonBox} = Qt4::DialogButtonBox();
    this->buttonBox->addButton(this->downloadButton, Qt4::DialogButtonBox::ActionRole());
    this->buttonBox->addButton(this->quitButton, Qt4::DialogButtonBox::RejectRole());

    this->{progressDialog} = Qt4::ProgressDialog(this);

    this->connect(this->fileList, SIGNAL 'itemActivated(QTreeWidgetItem *, int)',
            this, SLOT 'processItem(QTreeWidgetItem *, int)');
    this->connect(this->fileList, SIGNAL 'currentItemChanged(QTreeWidgetItem *, QTreeWidgetItem *)',
            this, SLOT 'enableDownloadButton()');
    this->connect(this->progressDialog, SIGNAL 'canceled()', this, SLOT 'cancelDownload()');
    this->connect(this->connectButton, SIGNAL 'clicked()', this, SLOT 'connectOrDisconnect()');
    this->connect(this->cdToParentButton, SIGNAL 'clicked()', this, SLOT 'cdToParent()');
    this->connect(this->downloadButton, SIGNAL 'clicked()', this, SLOT 'downloadFile()');
    this->connect(this->quitButton, SIGNAL 'clicked()', this, SLOT 'close()');

    my $topLayout = Qt4::HBoxLayout();
    $topLayout->addWidget(this->ftpServerLabel);
    $topLayout->addWidget(this->ftpServerLineEdit);
    $topLayout->addWidget(this->cdToParentButton);
    $topLayout->addWidget(this->connectButton);
    
    my $mainLayout = Qt4::VBoxLayout();
    $mainLayout->addLayout($topLayout);
    $mainLayout->addWidget(this->fileList);
    $mainLayout->addWidget(this->statusLabel);
    $mainLayout->addWidget(this->buttonBox);
    this->setLayout($mainLayout);

    this->setWindowTitle(this->tr('FTP'));
}

sub sizeHint
{
    return Qt4::Size(500, 300);
}

#[0]
sub connectOrDisconnect
{
    if (this->ftp) {
        this->ftp->abort();
        this->ftp->deleteLater();
        this->{ftp} = 0;
#[0]
        this->fileList->setEnabled(0);
        this->cdToParentButton->setEnabled(0);
        this->downloadButton->setEnabled(0);
        this->connectButton->setEnabled(1);
        this->connectButton->setText(this->tr('Connect'));
        this->setCursor(Qt4::Cursor(Qt4::ArrowCursor()));
        return;
    }

    this->setCursor(Qt4::Cursor(Qt4::WaitCursor()));

#[1]    
    this->{ftp} = Qt4::Ftp(this);
    this->connect(this->ftp, SIGNAL 'commandFinished(int, bool)',
            this, SLOT 'ftpCommandFinished(int, bool)');
    this->connect(this->ftp, SIGNAL 'listInfo(const QUrlInfo &)',
            this, SLOT 'addToList(const QUrlInfo &)');
    this->connect(this->ftp, SIGNAL 'dataTransferProgress(qint64, qint64)',
            this, SLOT 'updateDataTransferProgress(qint64, qint64)');

    this->fileList->clear();
    this->{currentPath} = '';
    this->{isDirectory} = {};
#[1]

#[2]
    my $url = Qt4::Url(this->ftpServerLineEdit->text());
    if (!$url->isValid() || lc $url->scheme() ne 'ftp') {
        this->ftp->connectToHost(this->ftpServerLineEdit->text(), 21);
        this->ftp->login();
    } else {
        this->ftp->connectToHost($url->host(), $url->port(21));

        if (!$url->userName()->isEmpty()) {
            this->ftp->login(Qt4::Url::fromPercentEncoding($url->userName()), $url->password());
        }
        else {
            this->ftp->login();
        }
        if ($url->path()) {
            this->ftp->cd($url->path());
        }
    }
#[2]

    this->fileList->setEnabled(1);
    this->connectButton->setEnabled(0);
    this->connectButton->setText(this->tr('Disconnect'));
    this->statusLabel->setText( sprintf this->tr('Connecting to FTP server %s...'),
                         this->ftpServerLineEdit->text());
}

#[3]
sub downloadFile
{
    my $fileName = this->fileList->currentItem()->text(0);
#[3]
    if (Qt4::File::exists($fileName)) {
        Qt4::MessageBox::information(this, this->tr('FTP'),
                          sprintf this->tr('There already exists a file called %s in ' .
                                    'the current directory.'),
                                  $fileName);
        return;
    }

#[4]
    this->{file} = Qt4::File($fileName);
    if (!this->file->open(Qt4::IODevice::WriteOnly())) {
        Qt4::MessageBox::information(this, this->tr('FTP'),
                            sprintf this->tr('Unable to save the file %s: %s.'),
                                 $fileName, this->file->errorString());
        this->{file} = 0;
        return;
    }

    this->ftp->get(this->fileList->currentItem()->text(0), this->file);

    this->progressDialog->setLabelText(sprintf this->tr('Downloading %s...'), $fileName);
    this->downloadButton->setEnabled(0);
    this->progressDialog->exec();
}
#[4]

#[5]
sub cancelDownload
{
    this->ftp->abort();
}
#[5]

#[6]
sub ftpCommandFinished
{
    my ($int, $error) = @_;
    this->setCursor(Qt4::Cursor(Qt4::ArrowCursor()));

    if (this->ftp->currentCommand() == Qt4::Ftp::ConnectToHost()) {
        if ($error) {
            Qt4::MessageBox::information(this, this->tr('FTP'),
                                sprintf this->tr('Unable to connect to the FTP server ' .
                                        'at %s. Please check that the host ' .
                                        'name is correct.'),
                                     this->ftpServerLineEdit->text());
            this->connectOrDisconnect();
            return;
        }
        this->statusLabel->setText(sprintf this->tr('Logged onto %s.'),
                             this->ftpServerLineEdit->text());
        this->fileList->setFocus();
        this->downloadButton->setDefault(1);
        this->connectButton->setEnabled(1);
        return;
    }
#[6]

#[7]
    if (this->ftp->currentCommand() == Qt4::Ftp::Login()) {
        this->ftp->list();
    }
#[7]

#[8]
    if (this->ftp->currentCommand() == Qt4::Ftp::Get()) {
        if ($error) {
            this->statusLabel->setText(sprintf this->tr('Canceled download of %s.'),
                                 this->file->fileName());
            this->file->close();
            this->file->remove();
        } else {
            this->statusLabel->setText(sprintf this->tr('Downloaded %s to current directory.'),
                                 this->file->fileName());
            this->file->close();
        }
        this->{file} = 0;
        this->enableDownloadButton();
        this->progressDialog->hide();
#[8]
#[9]
    } elsif (this->ftp->currentCommand() == Qt4::Ftp::List()) {
        if (!this->isDirectory) {
            this->fileList->addTopLevelItem(Qt4::TreeWidgetItem([this->tr('<empty>')]));
            this->fileList->setEnabled(0);
        }
    }
#[9]
}

#[10]
sub addToList
{
    my ($urlInfo) = @_;
    my $item = Qt4::TreeWidgetItem();
    $item->setText(0, $urlInfo->name());
    $item->setText(1, $urlInfo->size());
    $item->setText(2, $urlInfo->owner());
    $item->setText(3, $urlInfo->group());
    $item->setText(4, $urlInfo->lastModified()->toString('MMM dd yyyy'));

    my $pixmap = Qt4::Pixmap($urlInfo->isDir() ? 'images/dir.png' : 'images/file.png');
    $item->setIcon(0, Qt4::Icon($pixmap));

    this->isDirectory->{$urlInfo->name()} = $urlInfo->isDir();
    this->fileList->addTopLevelItem($item);
    if (!this->fileList->currentItem()) {
        this->fileList->setCurrentItem(this->fileList->topLevelItem(0));
        this->fileList->setEnabled(1);
    }
}
#[10]

#[11]
sub processItem
{
    my ($item) = @_;
    my $name = $item->text(0);
    if (this->isDirectory->{$name}) {
        this->fileList->clear();
        this->{isDirectory} = {};
        this->{currentPath} .= '/' . $name;
        this->ftp->cd($name);
        this->ftp->list();
        this->cdToParentButton->setEnabled(1);
        this->setCursor(Qt4::Cursor(Qt4::WaitCursor()));
        return;
    }
}
#[11]

#[12]
sub cdToParent
{
    this->setCursor(Qt4::Cursor(Qt4::WaitCursor()));
    this->fileList->clear();
    this->{isDirectory} = {};
    this->{currentPath} =~ s@\/[^/]*$@@g;
    if (!this->currentPath) {
        this->cdToParentButton->setEnabled(0);
        this->ftp->cd('/');
    } else {
        this->ftp->cd(this->currentPath);
    }
    this->ftp->list();
}
#[12]

#[13]
sub updateDataTransferProgress
{
    my ($readBytes, $totalBytes) = @_;
    this->progressDialog->setMaximum($totalBytes);
    this->progressDialog->setValue($readBytes);
}
#[13]

#[14]
sub enableDownloadButton
{
    my $current = this->fileList->currentItem();
    if ($current) {
        my $currentFile = $current->text(0);
        this->downloadButton->setEnabled(!this->isDirectory->{$currentFile});
    } else {
        this->downloadButton->setEnabled(0);
    }
}
#[14]

1;
