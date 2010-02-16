package DropSiteWindow;

use strict;
use warnings;
use Qt4;
# [DropSiteWindow header]
use Qt4::isa qw( Qt4::Widget );
use Qt4::slots
    updateFormatsTable => ['const QMimeData *'];
use DropArea;

sub dropArea() {
    return this->{dropArea};
}

sub abstractLabel() {
    return this->{abstractLabel};
}

sub formatsTable() {
    return this->{formatsTable};
}

sub clearButton() {
    return this->{clearButton};
}

sub quitButton() {
    return this->{quitButton};
}

sub buttonBox() {
    return this->{buttonBox};
}
# [DropSiteWindow header]

# [constructor part1]
sub NEW
{
    my ($class) = @_;
    $class->SUPER::NEW();
    this->{abstractLabel} = Qt4::Label(this->tr('This example accepts drags from other ' .
                                  'applications and displays the MIME types ' .
                                  'provided by the drag object.'));
    this->abstractLabel->setWordWrap(1);
    this->abstractLabel->adjustSize();
# [constructor part1]

# [constructor part2]
    this->{dropArea} = DropArea();
    this->connect(this->dropArea, SIGNAL 'changed(const QMimeData *)',
            this, SLOT 'updateFormatsTable(const QMimeData *)');
# [constructor part2]

# [constructor part3]
    my @labels = (this->tr('Format'), this->tr('Content'));

    this->{formatsTable} = Qt4::TableWidget();
    this->formatsTable->setColumnCount(2);
    this->formatsTable->setEditTriggers(Qt4::AbstractItemView::NoEditTriggers());
    this->formatsTable->setHorizontalHeaderLabels(\@labels);
    this->formatsTable->horizontalHeader()->setStretchLastSection(1);
# [constructor part3]

# [constructor part4]
    this->{clearButton} = Qt4::PushButton(this->tr('Clear'));
    this->{quitButton} = Qt4::PushButton(this->tr('Quit'));

    this->{buttonBox} = Qt4::DialogButtonBox();
    this->buttonBox->addButton(this->clearButton, Qt4::DialogButtonBox::ActionRole());
    this->buttonBox->addButton(this->quitButton, Qt4::DialogButtonBox::RejectRole());

    this->connect(this->quitButton, SIGNAL 'pressed()', this, SLOT 'close()');
    this->connect(this->clearButton, SIGNAL 'pressed()', this->dropArea, SLOT 'clear()');
# [constructor part4]

# [constructor part5]
    my $mainLayout = Qt4::VBoxLayout();
    $mainLayout->addWidget(this->abstractLabel);
    $mainLayout->addWidget(this->dropArea);
    $mainLayout->addWidget(this->formatsTable);
    $mainLayout->addWidget(this->buttonBox);
    this->setLayout($mainLayout);

    this->setWindowTitle(this->tr('Drop Site'));
    this->setMinimumSize(350, 500);
}
# [constructor part5]

# [updateFormatsTable() part1]
sub updateFormatsTable
{
    my ($mimeData) = @_;
    this->formatsTable->setRowCount(0);
    if (!$mimeData) {
        return;
    }
# [updateFormatsTable() part1]

# [updateFormatsTable() part2]        
    foreach my $format ( @{$mimeData->formats()} ) {
        my $formatItem = Qt4::TableWidgetItem($format);
        $formatItem->setFlags(Qt4::ItemIsEnabled());
        $formatItem->setTextAlignment(Qt4::AlignTop() | Qt4::AlignLeft());
# [updateFormatsTable() part2]

# [updateFormatsTable() part3]
        my $text;
        if ($format eq 'text/plain') {
            $text = $mimeData->text()->simplified();
        } elsif ($format eq 'text/html') {
            $text = $mimeData->html()->simplified();
        } elsif ($format eq 'text/uri-list') {
            my $urlList = $mimeData->urls();
            foreach my $url ( @{$urlList} ) {
                $text .= $url . ' ';
            }
        } else {
            my $data = $mimeData->data($format);
            for (my $i = 0; $i < $data->size() && $i < 32; ++$i) {
                my $hex = uc sprintf '%02x', $data->at($i);
                $text .= $hex . ' ';
            }
        }
# [updateFormatsTable() part3]   

# [updateFormatsTable() part4]
        my $row = this->formatsTable->rowCount();
        this->formatsTable->insertRow($row);
        this->formatsTable->setItem($row, 0, Qt4::TableWidgetItem($format));
        this->formatsTable->setItem($row, 1, Qt4::TableWidgetItem($text));
    }
    
    this->formatsTable->resizeColumnToContents(0);
}
# [updateFormatsTable() part4] 

1;
